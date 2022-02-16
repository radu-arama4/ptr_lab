defmodule TweetProcesser.Receiver do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    run_process()
    {:ok, []}
  end

  def handle_info(:run, state) do
    EventsourceEx.new("http://localhost:4000", stream_to: self())
  end

  defp run_process do
    Process.send_after(self(), :run, 2000)
  end

end

# "https://url.com/stream", stream_to: self
