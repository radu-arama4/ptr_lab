defmodule TweetProcesser.FlowManager do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{:workers => [], :wp_pid => opts[:wp_pid]})
  end

  @impl true
  def handle_cast({:send, message}, state) do
    {load_balancer_pid} =
      TweetProcesser.SiblingsAccesor.get_sibling(state[:wp_pid], TweetProcesser.LoadBalancer)

    GenServer.cast(load_balancer_pid, {state[:workers], message})
    {:noreply, state}
  end

  @impl true
  def handle_cast({:push, worker_pid}, state) do
    {:noreply,
     %{:workers => Enum.concat(state[:workers], [worker_pid]), :wp_pid => state[:wp_pid]}}
  end

  @impl true
  def init(opts) do
    IO.puts("Flow Manager initialized")
    {:ok, opts}
  end
end
