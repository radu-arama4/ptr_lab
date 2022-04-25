defmodule TweetProcesser.Counter do
  use GenServer

  def start_link(opts) do
    nr_of_messages = 0

    GenServer.start_link(
      __MODULE__,
      %{:nr_of_messages => nr_of_messages, :wp_pid => opts[:wp_pid]}
    )
  end

  @impl true
  def init(opts) do
    IO.puts("Counter initialized")
    run_reset_process()
    {:ok, opts}
  end

  @impl true
  def handle_cast({:push}, state) do
    {:noreply, %{:nr_of_messages => state[:nr_of_messages] + 1, :wp_pid => state[:wp_pid]}}
  end

  @impl true
  def handle_cast({:reset}, state) do
    {:noreply, %{:nr_of_messages => 0, :wp_pid => state[:wp_pid]}}
  end

  @impl true
  def handle_info(:reset, state) do
    check_nr_of_messages(state)
    run_reset_process()
    {:noreply, %{:nr_of_messages => 0, :wp_pid => state[:wp_pid]}}
  end

  def check_nr_of_messages(state) do
    nr_of_messages = state[:nr_of_messages]

    {autoscaller_pid} =
      TweetProcesser.SiblingsAccesor.get_sibling(state[:wp_pid], TweetProcesser.AutoScaller)

    nr_of_workers = GenServer.call(autoscaller_pid, {:get, :nr_of_workers})

    IO.inspect(nr_of_workers)

    desired_nr_of_workers = round(nr_of_messages / 11)

    cond do
      nr_of_workers < desired_nr_of_workers ->
        workers_to_add = desired_nr_of_workers - nr_of_workers
        add_new_workers(workers_to_add, autoscaller_pid)

      nr_of_workers > desired_nr_of_workers ->
        workers_to_remove = nr_of_workers - desired_nr_of_workers

        Enum.each(0..workers_to_remove, fn _x ->
          GenServer.cast(autoscaller_pid, {:remove})
        end)

      true ->
        IO.puts("Everything fine!")
    end
  end

  def add_new_workers(nr_of_workers, autoscaller_pid) do
    Enum.each(0..nr_of_workers, fn _x ->
      GenServer.cast(autoscaller_pid, {:push})
    end)
  end

  defp run_reset_process do
    Process.send_after(self(), :reset, 1000)
  end
end
