defmodule TweetProcesser.Receiver do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    run_process()
    {:ok, []}
  end

  defp run_process() do
    DynamicSupervisor.start_child(TweetProcesser.DummySupervisor, TweetProcesser.Worker)
    DynamicSupervisor.start_child(TweetProcesser.DummySupervisor, TweetProcesser.Worker)
    EventsourceEx.new("http://localhost:4000/tweets/1",stream_to: self())
  end

end
