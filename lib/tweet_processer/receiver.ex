defmodule TweetProcesser.Receiver do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    run_process()
    {:ok, []}
  end

  defp run_process do
    EventsourceEx.new("http://localhost:4000/tweets/1", stream_to: self())
  end

end

# "https://url.com/stream", stream_to: self
