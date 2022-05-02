defmodule TweetProcesser.Receiver2 do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [text: ""], name: __MODULE__)
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
  def handle_call({:get, word_to_check}, _from, state) do
    list = String.split(state[:text], "\r\n")

    default_score = 0

    elem =
      Enum.find(list, nil, fn value ->
        [word, _score] = String.split(value, "\t")
        word == word_to_check
      end)

    if elem != nil do
      [_word, score] = String.split(elem, "\t")
      {:reply, score, state}
    else
      {:reply, default_score, state}
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
