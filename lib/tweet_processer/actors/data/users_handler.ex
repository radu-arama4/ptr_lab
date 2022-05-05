defmodule TweetProcesser.UsersHandler do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(
      __MODULE__,
      [],
      name: __MODULE__
    )
  end

  @impl true
  def init(opts) do
    {:ok, opts}
  end

  @impl true
  def handle_cast({:check_user, tweets, pid}, state) do
    for tweet <- tweets do
      user = tweet["user"]

      parameter = %{"screen_name" => user["screen_name"]}
      found_user = check_existing_user(parameter, pid)

      current_ratio = tweet["engagement_ratio"]

      if found_user == {nil} do
        user = Map.put(user, "total_engagement_ratio", current_ratio)
        user = Map.put(user, "engagement_ratios", [current_ratio])
        IO.puts("Storing new user in DB.")
        Mongo.insert_one(pid, "users", user)
      else
        IO.puts("Already existing user found - " <> "#{inspect(user["screen_name"])}")

        update_existing_user(parameter, pid, current_ratio, found_user)
      end
    end

    {:noreply, state}
  end

  defp check_existing_user(parameter, pid) do
    found_user = Mongo.find_one(pid, "users", parameter)
    {found_user}
  end

  defp update_existing_user(parameter, pid, ratio, user) do
    {right_user} = user

    ratios = right_user["engagement_ratios"]
    ratios = Enum.concat(ratios, [ratio])

    ratio_sum =
      Enum.reduce(ratios, 0, fn ratio, sum ->
        sum + ratio
      end)

    total_ratio = ratio_sum / length(ratios)

    IO.puts(
      "Updating the total engagement ratio to - " <>
        "#{inspect(total_ratio)}"
    )

    Mongo.update_one(pid, "users", parameter, "$set": [engagement_ratios: ratios])
    Mongo.update_one(pid, "users", parameter, "$set": [total_engagement_ratio: total_ratio])
  end
end
