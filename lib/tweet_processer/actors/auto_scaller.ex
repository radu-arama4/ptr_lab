defmodule TweetProcesser.AutoScaller do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [workers: %{}, opts: opts], name: __MODULE__)
  end

  def get_number_of_workers() do
    workers = GenServer.call(__MODULE__, {:get, :workers})
    {Enum.count(workers)}
  end

  @impl true
  def handle_call({:get, :workers}, _from, state) do
    {:reply, state[:workers], state}
  end

  @impl true
  def handle_cast({:get}, state) do
    {:ok, state}
  end

  def cast_new_worker() do
    {:ok, worker_pid} =
      DynamicSupervisor.start_child(TweetProcesser.DummySupervisor, TweetProcesser.Worker)

    GenServer.cast(__MODULE__, {:push, worker_pid})
  end

  def add_new_workers(nr_of_workers) do
    Enum.each(0..nr_of_workers, fn _x ->
      cast_new_worker()
    end)
  end

  def remove_worker() do
    GenServer.cast(__MODULE__, {:remove})
  end

  @impl true
  def handle_cast({:remove}, state) do
    worker = Enum.take_random(state[:workers], 1)
    {worker_pid, _some_pid} = Enum.at(worker, 0)
    DynamicSupervisor.terminate_child(TweetProcesser.DummySupervisor, worker_pid)
    {:noreply, [workers: Map.delete(state[:workers], worker_pid), opts: state[:opts]]}
  end

  @impl true
  def handle_cast({:push, worker_pid}, state) do
    {:noreply, [workers: Map.put(state[:workers], worker_pid, worker_pid), opts: state[:opts]]}
  end

  @impl true
  def init(opts) do
    {:ok, opts}
  end
end
