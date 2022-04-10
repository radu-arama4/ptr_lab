defmodule TweetProcesser.WorkerPool do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, opts)
  end

  @impl true
  def init(opts) do
    type_of_worker = opts[:type_of_worker]

    children = [
      {TweetProcesser.AutoScaller, [name: AutoScaller, type_of_worker: type_of_worker, wp_pid: self()]},
      {TweetProcesser.Counter, [name: Counter, type_of_worker: type_of_worker, wp_pid: self()]},
      {TweetProcesser.LoadBalancer, [name: LoadBalancer, type_of_worker: type_of_worker, wp_pid: self()]},
      {TweetProcesser.FlowManager, [name: FlowManager, type_of_worker: type_of_worker, wp_pid: self()]},
      {DynamicSupervisor,[strategy: :one_for_one, name: TweetProcesser.DummySupervisor, type_of_worker: type_of_worker, wp_pid: self()]},
      {TweetProcesser.Receiver, [name: Receiver, type_of_worker: type_of_worker, wp_pid: self()]}
    ]

    opts = [strategy: :one_for_one, name: TweetProcesser.WorkerPool]

    Supervisor.init(children, opts)
  end

end

#Supervisor.which_children(TweetProcesser.WorkerPool)
