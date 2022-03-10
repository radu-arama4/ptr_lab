defmodule TweetProcesser.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {TweetProcesser.Counter, [name: Counter]},
      {TweetProcesser.AutoScaller, [name: AutoScaller]},
      {TweetProcesser.LoadBalancer, [name: LoadBalancer]},
      {TweetProcesser.FlowManager, [name: FlowManager]},
      {DynamicSupervisor,[strategy: :one_for_one, name: TweetProcesser.DummySupervisor]},
      {TweetProcesser.Receiver, [name: Receiver]}
    ]

    opts = [strategy: :one_for_one, name: TweetProcesser.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
