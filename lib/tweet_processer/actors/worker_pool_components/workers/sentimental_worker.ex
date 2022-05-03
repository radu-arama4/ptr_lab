defmodule TweetProcesser.SentimentalWorker do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  @impl true
  def init(opts) do
    IO.puts("New sentimental worker!")
    send_pid_to_flow_manager(opts[:wp_pid])
    {:ok, opts}
  end

  defp send_pid_to_flow_manager(wp_pid) do
    {flow_manager_pid} =
      TweetProcesser.SiblingsAccesor.get_sibling(wp_pid, TweetProcesser.FlowManager)

    GenServer.cast(flow_manager_pid, {:push, self()})
  end

  defp process_sentimental_score(message) do
    text = message["text"]
    words = String.split(text)

    sentimental_score =
      Enum.reduce(words, 0, fn word, sum ->
        score = GenServer.call(TweetProcesser.Receiver2, {:get, word})

        if score != 0 do
          {int_val, ""} = Integer.parse(score)
          sum + int_val
        else
          sum
        end
      end)

    message = Map.put(message, "sentimental_score", sentimental_score / length(words))

    GenServer.cast(TweetProcesser.Aggregator, {:put_sent, message})

    if message["retweeted_status"] != nil do
      process_sentimental_score(message["retweeted_status"])
    end
  end

  @impl true
  def handle_info(message, state) do
    random_number = Enum.random(50..500)
    :timer.sleep(random_number)

    case JSON.decode(message.data) do
      {:ok, tweet} ->
        process_sentimental_score(tweet["message"]["tweet"])

      {:error, _error} ->
        IO.puts("PANIC!!! KILLING WORKER WITH PID " <> "#{inspect(self())}")
        Process.exit(self(), :normal)
    end

    {:noreply, state}
  end
end
