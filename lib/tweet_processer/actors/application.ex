defmodule TweetProcesser.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # {TweetProcesser.FlowManager, [name: FlowManager]},
      # {TweetProcesser.MainSupervisor, [name: MainSupervisor]},
      # {TweetProcesser.Receiver, [name: Receiver]}
    ]

    {:ok, flow_manager_pid} = TweetProcesser.FlowManager.start_link([])

    _flow_manager_ref = Process.monitor(flow_manager_pid)

    {:ok, main_supervisor_pid} = TweetProcesser.MainSupervisor.start_link([])

    _main_supervisor_ref =  Process.monitor(main_supervisor_pid)

    {:ok, receiver_pid} = TweetProcesser.Receiver.start_link([%{"main_supervisor_pid"=>main_supervisor_pid}])

    _receiver_ref = Process.monitor(receiver_pid)

    opts = [strategy: :one_for_one, name: TweetProcesser.Supervisor]
    # Supervisor.start_link(TweetProcesser.FlowManager, opts)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    Supervisor.start_link(children, opts)

    #Supervisor.which_children(TweetProcesser.Supervisor)
  end
end
