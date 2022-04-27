defmodule TweetProcesser.Receiver2 do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    IO.puts("Receiver2 initialized")
    run_process(opts)
    {:ok, opts}
  end

  defp run_process(opts) do
    # will extract data from second stream

    main_pid = opts[:main_pid]

    HTTPoison.get!("http://localhost:4000/emotion_values", [],
      recv_timeout: :infinity,
      stream_to: self()
    )

    # EventsourceEx.new("http://localhost:4000/emotion_values", stream_to: main_pid)
  end

  @impl true
  def handle_info(%HTTPoison.AsyncEnd{id: id}, _state) do
    {:noreply, nil}
  end

  @impl true
  def handle_info(%HTTPoison.AsyncStatus{code: code, id: id}, _state) do
    {:noreply, nil}
  end

  @impl true
  def handle_info(%HTTPoison.AsyncHeaders{headers: headers, id: id}, _state) do
    {:noreply, nil}
  end

  @impl true
  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, _state) do
    # My use case assumes that each message contains two rows (event: and data:)
    # case Regex.run(~r/^event:(\w+)\ndata:({.+})\n\n$/, chunk) do
    #   [_, event, data] ->
    #     _json = Json.decode!(data)

    #     case event do
    #       "poke" -> IO.puts("Poke received: #{data}")
    #       "data" -> IO.puts("Data received: #{data}")
    #     end

    #   nil ->
    #     raise "Don't know how to parse received chunk: \"#{chunk}\""
    # end

    IO.inspect(chunk)

    {:noreply, nil}
  end
end
