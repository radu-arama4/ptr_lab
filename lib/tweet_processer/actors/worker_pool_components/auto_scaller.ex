defmodule TweetProcesser.AutoScaller do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      workers: %{},
      type_of_worker: opts[:type_of_worker],
      wp_pid: opts[:wp_pid]
    )
  end

  @impl true
  def handle_call({:get, :workers}, _from, state) do
    {:reply, state[:workers], state}
  end

  @impl true
  def handle_call({:get, :nr_of_workers}, _from, state) do
    {:reply, Enum.count(state[:workers]), state}
  end

  @impl true
  def handle_cast({:remove}, state) do
    worker = Enum.take_random(state[:workers], 1)
    {worker_pid, _some_pid} = Enum.at(worker, 0)

    {worker_supervisor_pid} =
      TweetProcesser.SiblingsAccesor.get_sibling(state[:wp_pid], TweetProcesser.DummySupervisor)

    DynamicSupervisor.terminate_child(worker_supervisor_pid, worker_pid)

    {:noreply,
     [
       workers: Map.delete(state[:workers], worker_pid),
       type_of_worker: state[:type_of_worker],
       wp_pid: state[:wp_pid]
     ]}
  end

  @impl true
  def handle_cast({:push}, state) do
    {worker_supervisor_pid} =
      TweetProcesser.SiblingsAccesor.get_sibling(state[:wp_pid], TweetProcesser.DummySupervisor)

    {:ok, worker_pid} =
      DynamicSupervisor.start_child(
        worker_supervisor_pid,
        {TweetProcesser.Worker, [type_of_worker: state[:type_of_worker], wp_pid: state[:wp_pid]]}
      )

    {:noreply,
     [
       workers: Map.put(state[:workers], worker_pid, worker_pid),
       type_of_worker: state[:type_of_worker],
       wp_pid: state[:wp_pid]
     ]}
  end

  @impl true
  def init(opts) do
    IO.puts("Auto Scaller initialized")
    {:ok, opts}
  end
end
