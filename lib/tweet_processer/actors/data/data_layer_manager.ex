defmodule TweetProcesser.DataLayerManager do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [tweets: []], name: __MODULE__)
  end

  @impl true
  def handle_info({:tweet, tweet}, state) do
    {:noreply, [tweets: Enum.concat(state[:tweets], [tweet])]}
  end

  @impl true
  def handle_info({:batch, size}, state) do
    if length(state[:tweets]) >= size do
      IO.puts("Storing to DB " <> "#{inspect(size)}" <> " tweets!")

      tweets_to_store = Enum.take(state[:tweets], size)

      {:ok, pid} = Mongo.start_link(url: "mongodb://localhost:27018/tweet_processor")

      for tweet <- tweets_to_store do
        user = tweet["user"]
        Mongo.insert_one(pid, "users", user)
      end

      {:ok, _result} = Mongo.insert_many(pid, "tweets", tweets_to_store)

      {:noreply, [tweets: Enum.drop(state[:tweets], size)]}
    else
      {:noreply, state}
    end
  end

  @impl true
  def init(opts) do
    {:ok, opts}
  end
end
