defmodule TweetProcesser.Counter do
  use GenServer

  def start_link(_opts) do
    state = 0
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    run_reset_process()
    {:ok, opts}
  end

  @impl true
  def handle_cast({:push}, state) do
    {:noreply, state + 1}
  end

  @impl true
  def handle_cast({:reset}, _state) do
    {:noreply, 0}
  end

  @impl true
  def handle_info(:reset, state) do
    check_nr_of_messages(state)
    run_reset_process()
    {:noreply, 0}
  end

  def check_nr_of_messages(nr_of_messages) do
    {nr_of_workers} = TweetProcesser.AutoScaller.get_number_of_workers()

    desired_nr_of_workers = round(nr_of_messages / 11)

    IO.inspect(nr_of_workers)

    cond do
      nr_of_workers < desired_nr_of_workers ->
        workers_to_add = desired_nr_of_workers - nr_of_workers
        TweetProcesser.AutoScaller.add_new_workers(workers_to_add)

      nr_of_workers > desired_nr_of_workers ->
        workers_to_remove = nr_of_workers - desired_nr_of_workers

        Enum.each(0..workers_to_remove, fn _x ->
          TweetProcesser.AutoScaller.remove_worker()
        end)

      true ->
        IO.puts("Everything fine!")
    end
  end

  defp run_reset_process do
    Process.send_after(self(), :reset, 1000)
  end
end
