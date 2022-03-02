defmodule TweetProcesser.DummySupervisor do
  use DynamicSupervisor

  def start_link(_opts) do
    DynamicSupervisor.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def new_child() do
    {:ok, _pid} = DynamicSupervisor.start_child(TweetProcesser.DummySupervisor, TweetProcesser.Worker)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
