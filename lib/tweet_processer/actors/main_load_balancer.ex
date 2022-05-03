defmodule TweetProcesser.MainLoadBalancer do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      %{:worker_pools => [], :wp_index => 0, :main_pid => opts[:main_pid]},
      name: __MODULE__
    )
  end

  @impl true
  def init(opts) do
    IO.puts("Main Load Balancer initialized")
    {:ok, opts}
  end

  def send_message_to_wp(wp, message) do
    {flow_manager_pid} =
      TweetProcesser.SiblingsAccesor.get_sibling(wp, TweetProcesser.FlowManager)

    {counter_pid} = TweetProcesser.SiblingsAccesor.get_sibling(wp, TweetProcesser.Counter)

    GenServer.cast(flow_manager_pid, {:send, message})
    GenServer.cast(counter_pid, {:push})
  end

  @impl true
  def handle_cast({:send, message}, state) do
    worker_pools_list = state[:worker_pools]

    Enum.each(worker_pools_list, fn wp -> send_message_to_wp(wp, message) end)

    {:noreply, state}
  end

  @impl true
  def handle_cast({:push, worker_pool}, state) do
    {:noreply,
     %{
       :worker_pools => Enum.concat(state[:worker_pools], [worker_pool]),
       :wp_index => state[:wp_index],
       :main_pid => state[:main_pid]
     }}
  end
end
