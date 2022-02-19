defmodule TweetProcesser.FlowManager do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    run_process()
    {:ok, []}
  end

  defp run_process do
    IO.puts("Hello from flow manager")
  end

end
