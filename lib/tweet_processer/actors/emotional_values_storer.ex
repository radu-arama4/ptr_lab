defmodule TweetProcesser.EmotionalValuesStorer do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, text: "", score: %{}, name: __MODULE__)
  end

  @impl true
  def handle_cast({:put, chunk}, state) do
    {:noreply, [text: state[:text] <> chunk, score: state[:score]]}
  end

  @impl true
  def handle_call({:get}, _from, state) do
    {:reply, ['re'], state}
  end

  @impl true
  def init(opts) do
    {:ok, opts}
  end
end
