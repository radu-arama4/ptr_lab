defmodule TweetProcesser.Receiver2 do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [text: "", score: %{}], name: __MODULE__)
  end

  @impl true
  def init(opts) do
    IO.puts("Receiver2 initialized")
    run_process()
    {:ok, opts}
  end

  defp run_process() do
    # will extract data from second stream
    HTTPoison.get!("http://localhost:4000/emotion_values", [],
      recv_timeout: :infinity,
      stream_to: self()
    )
  end

  @impl true
  def handle_call({:get}, _from, state) do
    if state[:score] == %{} do
      list = String.split(state[:text], "\r\n")

      map = %{}

      for value <- list do
        [word, score] = String.split(value, "\t")
        Map.put(map, word, score)
      end

      {:reply, map, [text: "", score: map]}
    else
      {:reply, state[:score], state}
    end
  end

  @impl true
  def handle_info(%HTTPoison.AsyncEnd{id: _id}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(%HTTPoison.AsyncStatus{code: _code, id: _id}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(%HTTPoison.AsyncHeaders{headers: _headers, id: _id}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, state) do
    current_text = state[:text]
    {:noreply, [text: current_text <> chunk, score: state[:score]]}
  end
end
