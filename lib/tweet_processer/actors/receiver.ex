defmodule TweetProcesser.Receiver do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    [map | _tail] = opts
    pid = Map.fetch(map, "main_supervisor_pid")
    run_process(pid)
    {:ok, []}
  end

  defp run_process(pid) do
    {:ok, real_pid} = pid
    EventsourceEx.new("http://localhost:4000/tweets/1",stream_to: real_pid)
  end

end

# "https://url.com/stream", stream_to: self
