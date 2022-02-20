defmodule TweetProcesser.FlowManager do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    run_process()
    {:ok, %{}}
  end

  # defp run_process do
  #   IO.puts "Hello from flow manager"
  # end

  # def send_message() do
  #   IO.puts "HELLO FROM FLOW"
  # end

  # def handle_call({:get_the_message}, from, state) do

  #   {:message, "Hello", state}
  # end

  #-----------------------

  @impl true
  def handle_info(:run, state) do
    IO.inspect(state)
    run_process()

    num =
      [1, 2, 3, "four"]
      |> Enum.random()
      |> Kernel.+(0)

    {:noreply, [num | state]}
  end

  defp run_process do
    Process.send_after(self(), :run, 2000)
  end

end
