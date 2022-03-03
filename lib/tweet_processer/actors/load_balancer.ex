defmodule TweetProcesser.LoadBalancer do
  use GenServer

  def start_link(_opts) do
    index = 0
    GenServer.start_link(__MODULE__, index, name: __MODULE__)
  end

  def distribute_message({list, message}) do
    GenServer.cast(__MODULE__, {list, message})
  end

  @impl true
  def handle_cast({list, message}, state) do
    cond do
      state > length(list)-1 ->
        {:noreply, 0}
      true ->
        worker = Enum.at(list, 0)
        Process.send(worker, message, [])
        {:noreply, state+1}
    end
  end

  @impl true
  def init(opts) do
    IO.puts "Load Balancer"
    {:ok, opts}
  end
end
