defmodule TweetProcesser.Receiver do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    run_process(opts)
    {:ok, []}
  end

  defp run_process(opts) do
    wp_pid = opts[:wp_pid]

    TweetProcesser.AutoScaller.add_new_workers(5)

    EventsourceEx.new("http://localhost:4000/tweets/1",stream_to: wp_pid)
  end

end
