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

  def new_message() do
    GenServer.cast(__MODULE__, {:push})
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
    GenServer.cast(__MODULE__, {:reset})
    check_nr_of_messages(state)
    run_reset_process()
    {:noreply, state}
  end

  def check_nr_of_messages(nr_of_messages) do
    nr_of_workers = TweetProcesser.AutoScaller.get_number_of_workers()

    IO.puts "NR. OF WORKERS"
    IO.inspect nr_of_workers

    cond do
      nr_of_messages > 200 ->
        if nr_of_workers < nr_of_messages/2 do
          IO.puts("***Adding 20 workers***")
          TweetProcesser.AutoScaller.add_new_workers(20)
        end

      nr_of_messages > 100 ->
        IO.puts("***Adding 10 workers***")
        TweetProcesser.AutoScaller.add_new_workers(10)

      nr_of_messages > 25 ->
        IO.puts("***Adding 5 workers***")
        TweetProcesser.AutoScaller.add_new_workers(5)

      nr_of_messages <= 25 ->
        if nr_of_workers > nr_of_messages do
          IO.puts("***Decreasing the number of workers***")
          TweetProcesser.AutoScaller.remove_worker()
        end
    end
  end

  defp run_reset_process do
    Process.send_after(self(), :reset, 1000)
  end
end
