defmodule TweetProcesser.Receiver2 do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    IO.puts("Receiver2 initialized")
    run_process(opts)
    {:ok, opts}
  end

  defp run_process(opts) do
    # will extract data from second stream

    main_pid = opts[:main_pid]
    EventsourceEx.new("", stream_to: main_pid)
  end
end
