defmodule TweetProcesser.Receiver do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @spec init(nonempty_maybe_improper_list) :: {:ok, []}
  def init(opts) do
    # [map | _tail] = opts
    # pid = Map.fetch(map, "main_supervisor_pid")
    # EventsourceEx.new("http://localhost:4000/tweets/1",stream_to: self)
    run_process()
    {:ok, []}
  end

  defp run_process() do
    # {:ok, real_pid} = pid
    EventsourceEx.new("http://localhost:4000/tweets/1",stream_to: self())
  end

end

# "https://url.com/stream", stream_to: self
