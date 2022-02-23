defmodule TweetProcesser.MainSupervisor do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_cast(ceva) do
    GenServer.cast(__MODULE__, {:push, ceva})
  end

  @impl true
  def handle_cast({:push, element}, state) do
    # children = Supervisor.which_children(TweetProcesser.MainSupervisor)
    # name = Registry.lookup(TweetProcesser.Worker, Worker1)
    # pid = Process.whereis(:worker_1)
    IO.inspect element
    {:noreply, [element | state]}
  end

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end
  # @impl true
  # def init(:ok) do
  #   children = [
  #     {TweetProcesser.Worker, [name: :worker_1]},
  #     {TweetProcesser.Worker, [name: :worker_2]},
  #     {TweetProcesser.Worker, [name: :worker_3]},
  #     {TweetProcesser.Worker, [name: :worker_4]}
  #   ]

  #   nr_of_workers = 4

  #   IO.puts nr_of_workers

  #   opts = [strategy: :one_for_one, name: TweetProcesser.MainSupervisor]

  #   Supervisor.init(children, opts)
  # end
end
