defmodule TweetProcesser.Batcher do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      [
        max_tweets: opts[:max_tweets],
        batching_size: opts[:batch_size],
        batching_time_frame: opts[:time]
      ],
      name: __MODULE__
    )
  end

  @impl true
  def init(opts) do
    {timer_ref} = perform_batching(opts[:batching_time_frame])
    check_max_size()

    {:ok,
     [
       tweets: [],
       batching_size: opts[:batching_size],
       batching_time_frame: opts[:batching_time_frame],
       max_tweets: opts[:max_tweets],
       timer_ref: timer_ref
     ]}
  end

  @impl true
  def handle_info({:batch}, state) do
    Process.send(TweetProcesser.DataLayerManager, {:batch, state[:batching_size]}, [])

    perform_batching(state[:batching_time_frame])
    {:noreply, state}
  end

  @impl true
  def handle_info({:batch_continuous}, state) do
    nr_of_tweets = GenServer.call(TweetProcesser.DataLayerManager, {:get_nr_of_tweets})

    if state[:max_tweets] <= nr_of_tweets do
      # reset timer
      Process.cancel_timer(state[:timer_ref])
      IO.puts("Max nr. of tweets reached. Storing existing tweets to DB!")
      Process.send(TweetProcesser.DataLayerManager, {:batch, state[:max_tweets]}, [])
    end

    check_max_size()

    {:noreply, state}
  end

  defp check_max_size() do
    Process.send_after(self(), {:batch_continuous}, 200)
  end

  defp perform_batching(time_frame) do
    timer_ref = Process.send_after(self(), {:batch}, time_frame)
    {timer_ref}
  end
end
