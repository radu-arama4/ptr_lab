defmodule TweetProcesser.Worker do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  @impl true
  def init(opts) do
    # IO.puts("New worker of type: ")
    # IO.inspect(opts[:type_of_worker])
    send_pid_to_flow_manager(opts[:wp_pid])
    {:ok, opts}
  end

  defp send_pid_to_flow_manager(wp_pid) do
    {flow_manager_pid} =
      TweetProcesser.SiblingsAccesor.get_sibling(wp_pid, TweetProcesser.FlowManager)

    GenServer.cast(flow_manager_pid, {:push, self()})
  end

  defp process_sentimental_score(message) do
    text = message["message"]["tweet"]["text"]
    words = String.split(text)

    for word <- words do
      # will get the score for this specific word
    end
  end

  defp process_engagement_ratio(message) do
    message = message["message"]["tweet"]
    user = message["user"]

    favorite_count = message["favorite_count"]
    retweet_count = message["retweet_count"]
    followers_count = user["followers_count"]

    engagement_ratio = (favorite_count + retweet_count) / followers_count

    IO.puts("engagement ratio: ")
    IO.inspect(engagement_ratio)
  end

  @impl true
  def handle_info(message, state) do
    random_number = Enum.random(50..500)
    :timer.sleep(random_number)

    case JSON.decode(message.data) do
      {:ok, tweet} ->
        case state[:type_of_worker] do
          "Sentimental" ->
            process_sentimental_score(tweet)

          "Engaged" ->
            process_engagement_ratio(tweet)
        end

      {:error, _error} ->
        IO.puts("PANIC!!! KILLING WORKER WITH PID " <> "#{inspect(self())}")
        Process.exit(self(), :normal)
    end

    {:noreply, state}
  end
end
