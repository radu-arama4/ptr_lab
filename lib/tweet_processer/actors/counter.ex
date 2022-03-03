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
    IO.puts nr_of_messages
    cond do
      nr_of_messages>200 ->
        IO.puts "Creating 30 new workers!"
        TweetProcesser.AutoScaller.add_new_workers(30)
      nr_of_messages>100 ->
        IO.puts "Creating 10 new workers!"
        TweetProcesser.AutoScaller.add_new_workers(10)
      nr_of_messages>25 ->
        IO.puts "Creating new 5 workers!"
        TweetProcesser.AutoScaller.add_new_workers(5)
      nr_of_messages<=25 ->
        IO.puts "Removing worker!"
        TweetProcesser.AutoScaller.remove_worker()
    end
  end

  defp run_reset_process do
    Process.send_after(self(), :reset, 1000)
  end
end
