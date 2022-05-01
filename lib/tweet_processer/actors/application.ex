defmodule TweetProcesser.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {TweetProcesser.DataLayerManager, []},
      {TweetProcesser.Aggregator, [name: TweetProcesser.Aggregator]},
      {TweetProcesser.MainLoadBalancer, [main_pid: self()]},
      Supervisor.child_spec(
        {TweetProcesser.WorkerPool,
         [name: TweetProcesser.WorkerPool2, type_of_worker: TweetProcesser.SentimentalWorker]},
        id: :wp2
      ),
      Supervisor.child_spec(
        {TweetProcesser.WorkerPool,
         [name: TweetProcesser.WorkerPool3, type_of_worker: TweetProcesser.EngagedWorker]},
        id: :wp3
      ),
      {TweetProcesser.Receiver, [name: Receiver, main_pid: self()]},
      {TweetProcesser.Receiver2, [name: Receiver2]},
      # here will be given the parameters
      {TweetProcesser.Batcher, []}
    ]

    opts = [strategy: :one_for_one, name: TweetProcesser.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
