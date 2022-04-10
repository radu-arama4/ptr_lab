defmodule TweetProcesser.WorkerPool do
  use GenServer

  def start_link(opts) do
    # IO.inspect opts[:type_of_worker]
    Supervisor.start_link(__MODULE__, opts, opts)
  end

  @impl true
  def init(opts) do
    type_of_worker = opts[:type_of_worker]

    children = [
      {TweetProcesser.AutoScaller, [name: AutoScaller, type_of_worker: type_of_worker]},
      {TweetProcesser.Counter, [name: Counter, type_of_worker: type_of_worker]},
      {TweetProcesser.LoadBalancer, [name: LoadBalancer, type_of_worker: type_of_worker]},
      {TweetProcesser.FlowManager, [name: FlowManager, type_of_worker: type_of_worker]},
      {DynamicSupervisor,[strategy: :one_for_one, name: TweetProcesser.DummySupervisor, type_of_worker: type_of_worker]},
      {TweetProcesser.Receiver, [name: Receiver, type_of_worker: type_of_worker]}
    ]

    opts = [strategy: :one_for_one, name: TweetProcesser.WorkerSupervisor]

    Supervisor.init(children, opts)
  end

end
