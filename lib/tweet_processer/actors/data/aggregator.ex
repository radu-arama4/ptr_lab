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
        IO.puts("FOUND MATCH FOR SENTIMENTAL!!!")
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
        IO.puts("FOUND MATCH FOR ENGAGEMENT!!!")
      end
    end

    {:noreply,
     [
       sentimental: state[:sentimental],
       engaged: Enum.concat(state[:engaged], [received_tweet]),
       ready: []
     ]}
  end

  @impl true
  def init(opts) do
    {:ok, opts}
  end
end
