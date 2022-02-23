defmodule TweetProcesser.DummySupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      Supervisor.child_spec({TweetProcesser.Worker, []}, id: :my_worker_1),
      Supervisor.child_spec({TweetProcesser.Worker, []}, id: :my_worker_2),
      Supervisor.child_spec({TweetProcesser.Worker, []}, id: :my_worker_3),
      Supervisor.child_spec({TweetProcesser.Worker, []}, id: :my_worker_4),
      Supervisor.child_spec({TweetProcesser.Worker, []}, id: :my_worker_5)
    ]

    opts = [strategy: :one_for_one, name: TweetProcesser.WorkerSupervisor]

    Supervisor.init(children, opts)
  end
end
