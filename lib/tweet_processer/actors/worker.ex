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
    if String.contains? message.data, "panic" do
      IO.puts "PANIC!!! KILLING WORKER WITH PID"
      IO.inspect self()
      Process.exit(self(), :normal)
    end

    IO.puts "Worker with PID:"
    IO.inspect self()
    IO.inspect message
    {:noreply, state}
  end
end
