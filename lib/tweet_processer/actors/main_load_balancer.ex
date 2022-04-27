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

  @impl true
  def handle_cast({:send, message}, state) do
    index = state[:wp_index]
    worker_pools_list = state[:worker_pools]

    current_worker_pool = Enum.at(worker_pools_list, index)

    index = index + 1

    {flow_manager_pid} =
      TweetProcesser.SiblingsAccesor.get_sibling(current_worker_pool, TweetProcesser.FlowManager)

    {counter_pid} =
      TweetProcesser.SiblingsAccesor.get_sibling(current_worker_pool, TweetProcesser.Counter)

    GenServer.cast(flow_manager_pid, {:send, message})
    GenServer.cast(counter_pid, {:push})

    cond do
      index > length(worker_pools_list) - 1 ->
        {:noreply,
         %{
           :worker_pools => state[:worker_pools],
           :wp_index => 0,
           :main_pid => state[:main_pid]
         }}

      true ->
        {:noreply,
         %{
           :worker_pools => state[:worker_pools],
           :wp_index => index,
           :main_pid => state[:main_pid]
         }}
    end
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