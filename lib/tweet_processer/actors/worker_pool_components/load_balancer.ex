defmodule TweetProcesser.LoadBalancer do
  use GenServer

  def start_link(opts) do
    index = 0

    GenServer.start_link(__MODULE__, %{:index => index, :wp_pid => opts[:wp_pid]})
  end

  def distribute_message({list, message}) do
    GenServer.cast(__MODULE__, {list, message})
  end

  @impl true
  def handle_cast({list, message}, state) do
    index = state[:index]

    cond do
      index > length(list) - 1 ->
        {:noreply, %{:index => 0, :wp_pid => state[:wp_pid]}}

      true ->
        worker = Enum.at(list, index)
        Process.send(worker, message, [])
        {:noreply, %{:index => index + 1, :wp_pid => state[:wp_pid]}}
    end
  end

  @impl true
  def init(opts) do
    IO.puts("Load Balancer initialized")
    {:ok, opts}
  end
end
