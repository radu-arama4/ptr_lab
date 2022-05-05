defmodule TweetProcesser.EngagedWorker do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  @impl true
  def init(opts) do
    IO.puts("New engaged worker!")
    send_pid_to_flow_manager(opts[:wp_pid])
    {:ok, opts}
  end

  defp send_pid_to_flow_manager(wp_pid) do
    {flow_manager_pid} =
      TweetProcesser.SiblingsAccesor.get_sibling(wp_pid, TweetProcesser.FlowManager)

    GenServer.cast(flow_manager_pid, {:push, self()})
  end

  defp process_engagement_ratio(message) do
    user = message["user"]

    favorite_count = message["favorite_count"]
    retweet_count = message["retweet_count"]
    followers_count = user["followers_count"]

    if followers_count != 0 do
      engagement_ratio = ((favorite_count + retweet_count) / followers_count) |> Float.round(2)
      message = Map.put(message, "engagement_ratio", engagement_ratio)
      GenServer.cast(TweetProcesser.Aggregator, {:put_eng, message})
    else
      message = Map.put(message, "engagement_ratio", 0)
      GenServer.cast(TweetProcesser.Aggregator, {:put_eng, message})
    end

    if message["retweeted_status"] != nil do
      process_engagement_ratio(message["retweeted_status"])
    end
  end

  @impl true
  def handle_info(message, state) do
    random_number = Enum.random(50..500)
    :timer.sleep(random_number)

    case JSON.decode(message.data) do
      {:ok, tweet} ->
        process_engagement_ratio(tweet["message"]["tweet"])

      {:error, _error} ->
        IO.puts("PANIC!!! KILLING WORKER WITH PID " <> "#{inspect(self())}")
        Process.exit(self(), :normal)
    end

    {:noreply, state}
  end
end
