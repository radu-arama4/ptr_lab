defmodule TweetProcesser.AutoScaller do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def cast_new_worker() do
    {:ok, worker_pid} = DynamicSupervisor.start_child(TweetProcesser.DummySupervisor, TweetProcesser.Worker)
    GenServer.cast(__MODULE__, {:push, worker_pid})
  end

  def remove_worker() do
    GenServer.cast(__MODULE__, {:remove})
  end

  def handle_cast({:remove}, state) do
    pid = Process.whereis(TweetProcesser.FlowManager)
    workers = :sys.get_state(pid)
    worker = Enum.take_random(workers, 1)

    {worker_pid, _some_pid} = Enum.at(worker, 0)

    DynamicSupervisor.terminate_child(TweetProcesser.DummySupervisor, worker_pid)

    Map.delete(state, worker_pid)
  end

  @impl true
  def handle_cast({:push, worker_pid}, state) do
    {:noreply, Map.put(state, worker_pid, worker_pid)}
  end

  @impl true
  def init(opts) do
    {:ok, opts}
  end
end
