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
    text = message["message"]["tweet"]["text"]
    message = message["message"]["tweet"]
    words = String.split(text)

    # map = GenServer.call(TweetProcesser.Receiver2, {:get})

    # IO.inspect(map)

    sentimental_score = 2

    message = Map.put(message, "sentimental_score", sentimental_score)

    GenServer.cast(TweetProcesser.Aggregator, {:put_sent, message})

    # for word <- words do
    #   # will get the score for this specific word
    # end
  end

  @impl true
  def handle_info(message, state) do
    random_number = Enum.random(50..500)
    :timer.sleep(random_number)

    case JSON.decode(message.data) do
      {:ok, tweet} ->
        process_sentimental_score(tweet)

      {:error, _error} ->
        IO.puts("PANIC!!! KILLING WORKER WITH PID " <> "#{inspect(self())}")
        Process.exit(self(), :normal)
    end

    {:noreply, state}
  end
end
