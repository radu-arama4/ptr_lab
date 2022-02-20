defmodule TweetProcesser.MainSupervisor do
  use GenServer
  use Supervisor

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  # def handle_cast(message) do
  #   IO.puts message
  #   {:noreply}
  # end

  def handle_cast({:push, element}, state) do
    IO.puts "new message!"
    {:noreply, [element | state]}
  end

  def init(:ok) do
    children = [
      TweetProcesser.Worker
    ]

    nr_of_workers = 4

    IO.puts nr_of_workers

    Supervisor.init(children, strategy: :one_for_one)
  end
end
