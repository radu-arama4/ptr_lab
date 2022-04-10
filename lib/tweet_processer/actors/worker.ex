defmodule TweetProcesser.Worker do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    send_pid_to_flow_manager()
    {:ok, []}
  end

  defp send_pid_to_flow_manager() do
    TweetProcesser.FlowManager.cast_new_worker(self())
  end

  @impl true
  def handle_info(message, state) do
    random_number = Enum.random(50..500)
    :timer.sleep(random_number)

    case JSON.decode(message.data) do
      {:ok, tweet} ->
        mess = tweet["message"]
        tweet_2 = mess["tweet"]
        # IO.puts("Worker with PID: " <> "#{inspect(self())}, #{tweet_2["text"]}")

      {:error, _error} ->
        # IO.puts("PANIC!!! KILLING WORKER WITH PID " <> "#{inspect(self())}")
        Process.exit(self(), :normal)
    end

    {:noreply, state}
  end
end
