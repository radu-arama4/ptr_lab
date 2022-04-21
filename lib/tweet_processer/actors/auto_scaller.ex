defmodule TweetProcesser.AutoScaller do
  use GenServer

  def start_link(opts) do
    IO.puts("Auto scaller started")
    GenServer.start_link(__MODULE__, [workers: %{}, opts: opts], name: __MODULE__)
  end

  def get_number_of_workers() do
    # here MODULE needs to be replaced with actual pid
    workers = GenServer.call(__MODULE__, {:get, :workers})
    {Enum.count(workers)}
  end

  @impl true
  def handle_call({:get, :workers}, _from, state) do
    opts = state[:opts]
    pid = opts[:wp_pid]
    IO.puts("Which children")
    IO.inspect(Supervisor.which_children(pid))
    {:reply, state[:workers], state}
  end

  @impl true
  def handle_cast({:get}, state) do
    {:ok, state}
  end

  def cast_new_worker() do
    {worker_supervisor_pid} =
      TweetProcesser.SiblingsAccesor.get_sibling(state[:wp_pid], TweetProcesser.DummySupervisor)

    {:ok, worker_pid} =
      DynamicSupervisor.start_child(
        TweetProcesser.DummySupervisor,
        {TweetProcesser.Worker, [type_of_worker: "Sentimental"]}
      )

    # to be replaced
    GenServer.cast(__MODULE__, {:push, worker_pid})
  end

  def add_new_workers(nr_of_workers) do
    Enum.each(0..nr_of_workers, fn _x ->
      cast_new_worker()
    end)
  end

  def remove_worker() do
    # to be replaced
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
