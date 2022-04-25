defmodule TweetProcesser.Receiver do
  use GenServer

  def start_link(opts) do
    IO.puts("Receiver initialized")
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    IO.puts("Receiver init")
    run_process(opts)
    {:ok, []}
  end

  defp run_process(opts) do
    wp_pid = opts[:wp_pid]

    EventsourceEx.new("http://localhost:4000/tweets/1", stream_to: wp_pid)
  end
end
