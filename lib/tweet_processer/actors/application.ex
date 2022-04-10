defmodule TweetProcesser.Application do
  use Application

  @impl true
  def start(_type, _args) do
    # here I should be able to define as many worker pools as I want
    # Example:
    # {TweetProcesser.Worker_Pool, [type: Sentiment]}
    # {TweetProcesser.Worker_Pool, [type: Engagement]}

    # Children: receiver, receiver_2, [worker_pool#1, worker_pool#2, worker_pool#3 ...], aggregator, batcher, data_layer_manager

    children = [
      {TweetProcesser.WorkerPool, [strategy: :one_for_one, name: TweetProcesser.WorkerPool, type_of_worker: "Sentimental"]}
    ]

    opts = [strategy: :one_for_one, name: TweetProcesser.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
