defmodule TweetProcesser.AutoScaller do
  use GenServer

  def start_link(opts) do
    IO.puts "Auto scaller started"
    GenServer.start_link(__MODULE__, [workers: %{}, opts: opts], name: __MODULE__)
  end

  def get_number_of_workers() do
    workers = GenServer.call(__MODULE__, {:get, :workers}) # here MODULE needs to be replaced with actual pid
    {Enum.count(workers)}
  end

  @impl true
  def handle_call({:get, :workers}, _from, state) do
    opts = state[:opts]
    pid = opts[:wp_pid]
    IO.puts "Which children"
    IO.inspect Supervisor.which_children(pid)
    {:reply, state[:workers], state}
  end

  @impl true
  def handle_cast({:get}, state) do
    {:ok, state}
  end

  def cast_new_worker() do
    {:ok, worker_pid} =
      DynamicSupervisor.start_child(TweetProcesser.DummySupervisor, {TweetProcesser.Worker, [type_of_worker: "Sentimental"]})

    GenServer.cast(__MODULE__, {:push, worker_pid}) # to be replaced
  end

  def add_new_workers(nr_of_workers) do
    Enum.each(0..nr_of_workers, fn _x ->
      cast_new_worker()
    end)
  end

  def remove_worker() do
    GenServer.cast(__MODULE__, {:remove}) # to be replaced
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
