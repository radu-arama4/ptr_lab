defmodule TweetProcesser.DataLayerManager do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [tweets: []], name: __MODULE__)
  end

  @impl true
  def handle_info({:tweet, tweet}, state) do
    IO.puts("Received tweet in data layer manager!")
    {:noreply, [tweets: Enum.concat(state[:tweets], [tweet])]}
  end

  @impl true
  def handle_info({:batch, size}, state) do
    IO.puts("Storing to db a batch frame with size " <> "#{inspect(size)}")

    {:noreply, state}
  end

  @impl true
  def init(opts) do
    {:ok, opts}
  end
end
