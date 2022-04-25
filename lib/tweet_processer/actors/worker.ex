defmodule TweetProcesser.Worker do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  @impl true
  def init(opts) do
    IO.puts("New worker of type: ")
    IO.inspect(opts[:type_of_worker])
    send_pid_to_flow_manager(opts[:wp_pid])
    {:ok, []}
  end

  defp send_pid_to_flow_manager(wp_pid) do
    {flow_manager_pid} =
      TweetProcesser.SiblingsAccesor.get_sibling(wp_pid, TweetProcesser.FlowManager)

    GenServer.cast(flow_manager_pid, {:push, self()})
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
