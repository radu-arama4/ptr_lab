defmodule TweetProcesser.Batcher do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      [tweets: [], batching_size: opts[:batch_size], batching_time_frame: opts[:time]],
      name: __MODULE__
    )
  end

  @impl true
  def init(opts) do
    perform_batching(opts[:batching_time_frame])
    {:ok, opts}
  end

  @impl true
  def handle_info({:batch}, state) do
    Process.send(TweetProcesser.DataLayerManager, {:batch, state[:batching_size]}, [])

    perform_batching(state[:batching_time_frame])
    {:noreply, state}
  end

  defp perform_batching(time_frame) do
    Process.send_after(self(), {:batch}, time_frame)
  end
end
