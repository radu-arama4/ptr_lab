defmodule TweetProcesser.DummySupervisor do
  use DynamicSupervisor

  def start_link(opts) do
    IO.puts("Dummy supervisor start link")
    DynamicSupervisor.start_link(__MODULE__, opts)
  end

  def new_child() do
    {:ok, _pid} =
      DynamicSupervisor.start_child(TweetProcesser.DummySupervisor, TweetProcesser.Worker)
  end

  @impl true
  def init(:ok) do
    IO.puts("Dummy supervisor started!")
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
