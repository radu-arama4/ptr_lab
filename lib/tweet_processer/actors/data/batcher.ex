defmodule TweetProcesser.Batcher do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [tweets: []], name: __MODULE__)
  end

  @impl true
  def init(opts) do
    perform_batching()
    {:ok, opts}
  end

  @impl true
  def handle_info({:batch}, state) do
    # will send message to data_layer_manager
    size = 5

    Process.send(TweetProcesser.DataLayerManager, {:batch, size}, [])

    perform_batching()
    {:noreply, state}
  end

  defp perform_batching() do
    Process.send_after(self(), {:batch}, 1000)
  end
end
