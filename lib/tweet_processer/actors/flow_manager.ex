defmodule TweetProcesser.FlowManager do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def send_new_message(message) do
    pid = Process.whereis(TweetProcesser.FlowManager)
    workers = :sys.get_state(pid)
    worker = Enum.take_random(workers, 1)

    {worker_pid, _some_pid} = Enum.at(worker, 0)

    Process.send(worker_pid, message, [])
    # Here Round Robin will be implemented
  end

  def cast_new_worker(worker_pid) do
    GenServer.cast(__MODULE__, {:push, worker_pid})
  end

  @impl true
  def handle_cast({:push, worker_pid}, state) do
    {:noreply, Map.put(state, worker_pid, worker_pid)}
  end
#separate into 2 workers and autoscaller may be the 3rd
  def get_pid() do
    self()
  end

  @impl true
  def init(opts) do
    IO.puts "Flow Manager initialized"
    {:ok, opts}
  end
end
