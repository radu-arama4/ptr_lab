defmodule TweetProcesser.FlowManager do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def send_new_message(message) do
    pid = Process.whereis(TweetProcesser.FlowManager)
    workers = :sys.get_state(pid)
    TweetProcesser.LoadBalancer.distribute_message({workers, message})
  end

  def cast_new_worker(worker_pid) do
    GenServer.cast(__MODULE__, {:push, worker_pid})
  end

  @impl true
  def handle_cast({:push, worker_pid}, state) do
    {:noreply, Enum.concat(state, [worker_pid])}
  end

  @impl true
  def init(opts) do
    IO.puts "Flow Manager initialized"
    {:ok, opts}
  end
end
