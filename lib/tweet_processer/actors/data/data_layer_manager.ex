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
    if length(state[:tweets]) >= size do
      IO.puts("Storing to db a batch frame with size " <> "#{inspect(size)}")

      tweets_to_store = Enum.take(state[:tweets], size)

      {:ok, pid} = Mongo.start_link(url: "mongodb://localhost:27018/tweet_processor")
      {:ok, result} = Mongo.insert_many(pid, "tweets", tweets_to_store)

      IO.inspect(result)
    end

    {:noreply, state}
  end

  @impl true
  def init(opts) do
    {:ok, opts}
  end
end
