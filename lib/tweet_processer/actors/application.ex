defmodule TweetProcesser.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {TweetProcesser.FlowManager, [name: FlowManager]},
      {TweetProcesser.DummySupervisor, [name: WorkerSupervisor]},
      {TweetProcesser.Receiver, [name: Receiver]}
    ]

    opts = [strategy: :one_for_one, name: TweetProcesser.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
