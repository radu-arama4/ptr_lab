defmodule TweetProcesser.Aggregator do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [sentimental: [], engaged: []], name: __MODULE__)
  end

  @impl true
  def handle_cast({:put_sent, received_tweet}, state) do
    list_of_engaged = state[:engaged]

    # verify with tweet_id
    for tweet <- list_of_engaged do
      if tweet["id"] == received_tweet["id"] do
        merge_tweets(received_tweet, tweet)
      end
    end

    {:noreply,
     [
       sentimental: Enum.concat(state[:sentimental], [received_tweet]),
       engaged: state[:engaged]
     ]}
  end

  @impl true
  def handle_cast({:put_eng, received_tweet}, state) do
    list_of_sentimental = state[:sentimental]

    for tweet <- list_of_sentimental do
      if tweet["id"] == received_tweet["id"] do
        merge_tweets(tweet, received_tweet)
      end
    end

    {:noreply,
     [
       sentimental: state[:sentimental],
       engaged: Enum.concat(state[:engaged], [received_tweet])
     ]}
  end

  @impl true
  def handle_info({:remove_sentimental, tweet}, state) do
    {:noreply, [sentimental: List.delete(state[:sentimental], tweet), engaged: state[:engaged]]}
  end

  @impl true
  def handle_info({:remove_engaged, tweet}, state) do
    {:noreply, [sentimental: state[:sentimental], engaged: List.delete(state[:engaged], tweet)]}
  end

  def merge_tweets(sentimental_tweet, engagement_tweet) do
    sentimental_score = sentimental_tweet["sentimental_score"]
    ready_tweet = Map.put(engagement_tweet, "sentimental_score", sentimental_score)

    Process.send(TweetProcesser.Aggregator, {:remove_sentimental, sentimental_tweet}, [])
    Process.send(TweetProcesser.Aggregator, {:remove_engaged, engagement_tweet}, [])

    Process.send(TweetProcesser.DataLayerManager, {:tweet, ready_tweet}, [])
  end

  @impl true
  def init(opts) do
    {:ok, opts}
  end
end
