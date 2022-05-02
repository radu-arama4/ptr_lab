defmodule TweetProcesser.DummySupervisor do
  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts)
  end

  @impl true
  def init(_opts) do
    IO.puts("Dummy Supervisor initialized")
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
