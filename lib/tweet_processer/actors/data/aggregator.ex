defmodule TweetProcesser.Aggregator do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [sentimental: [], engaged: [], ready: []], name: __MODULE__)
  end

  @impl true
  def handle_cast({:put_sent, tweet}, state) do
    IO.puts("NEW TWEET WITH SENTIMENT")
    IO.inspect(tweet["user"]["screen_name"])
    {:noreply, state}
  end

  @impl true
  def handle_cast({:put_eng, tweet}, state) do
    IO.puts("NEW TWEET WITH ENGAGEMENT")
    IO.inspect(tweet["user"]["screen_name"])
    {:noreply, state}
  end

  defp search do
  end

  @impl true
  def init(opts) do
    {:ok, opts}
  end
end
