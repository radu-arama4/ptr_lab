defmodule TweetProcesser.Worker do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    run_process()
    {:ok, []}
  end

  defp run_process do
    IO.puts("Hello from simple worker")
  end

end
