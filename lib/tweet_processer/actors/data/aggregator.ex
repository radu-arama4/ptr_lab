defmodule TweetProcesser.Aggregator do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [sentimental: [], engaged: [], ready: []], name: __MODULE__)
  end

  @impl true
  def handle_cast({:put_sent, received_tweet}, state) do
    list_of_engaged = state[:engaged]

    for tweet <- list_of_engaged do
      if tweet["user"]["screen_name"] == received_tweet["user"]["screen_name"] do
        merge_tweets(received_tweet, tweet)
      end
    end

    {:noreply,
     [
       sentimental: Enum.concat(state[:sentimental], [received_tweet]),
       engaged: state[:engaged],
       ready: state[:ready]
     ]}
  end

  @impl true
  def handle_cast({:put_eng, received_tweet}, state) do
    list_of_sentimental = state[:sentimental]

    for tweet <- list_of_sentimental do
      if tweet["user"]["screen_name"] == received_tweet["user"]["screen_name"] do
        merge_tweets(tweet, received_tweet)
      end
    end

    {:noreply,
     [
       sentimental: state[:sentimental],
       engaged: Enum.concat(state[:engaged], [received_tweet]),
       ready: []
     ]}
  end

  def merge_tweets(sentimental_tweet, engagement_tweet) do
    sentimental_score = sentimental_tweet["sentimental_score"]
    ready_tweet = Map.put(engagement_tweet, "sentimental_score", sentimental_score)

    Process.send(TweetProcesser.DataLayerManager, {:tweet, ready_tweet}, [])
  end

  @impl true
  def init(opts) do
    {:ok, opts}
  end
end
