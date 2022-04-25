defmodule TweetProcesser.Receiver do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    IO.puts("Receiver initialized")
    run_process(opts)
    {:ok, opts}
  end

  defp run_process(opts) do
    main_pid = opts[:main_pid]
    EventsourceEx.new("http://localhost:4000/tweets/1", stream_to: main_pid)
  end
end
