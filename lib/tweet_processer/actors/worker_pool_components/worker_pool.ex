defmodule TweetProcesser.WorkerPool do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, opts)
  end

  @impl true
  def init(opts) do
    type_of_worker = opts[:type_of_worker]

    # storing the current worker pool pid inside the state of main load balancer
    GenServer.cast(TweetProcesser.MainLoadBalancer, {:push, self()})

    children = [
      {TweetProcesser.AutoScaller,
       [name: AutoScaller, type_of_worker: type_of_worker, wp_pid: self()]},
      {TweetProcesser.Counter, [wp_pid: self()]},
      {TweetProcesser.LoadBalancer, [name: LoadBalancer, wp_pid: self()]},
      {TweetProcesser.FlowManager, [name: FlowManager, wp_pid: self()]},
      {TweetProcesser.DummySupervisor,
       [
         name: DummySupervisor,
         type_of_worker: type_of_worker,
         wp_pid: self()
       ]}
    ]

    opts = [strategy: :one_for_one, name: TweetProcesser.WorkerPool]

    IO.puts("Worker Pool initialized")

    Supervisor.init(children, opts)
  end
end

# Supervisor.which_children(TweetProcesser.WorkerPool)
