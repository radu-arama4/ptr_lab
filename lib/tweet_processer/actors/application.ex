defmodule TweetProcesser.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {TweetProcesser.MainLoadBalancer, [main_pid: self()]},
      Supervisor.child_spec(
        {TweetProcesser.WorkerPool,
         [name: TweetProcesser.WorkerPool, type_of_worker: "Sentimental"]},
        id: :wp1
      ),
      Supervisor.child_spec(
        {TweetProcesser.WorkerPool,
         [name: TweetProcesser.WorkerPool2, type_of_worker: "Engaged"]},
        id: :wp2
      ),
      {TweetProcesser.Receiver, [name: Receiver, main_pid: self()]},
      {TweetProcesser.Receiver2, [name: Receiver2, main_pid: self()]}
    ]

    opts = [strategy: :one_for_one, name: TweetProcesser.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
