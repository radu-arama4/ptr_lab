defmodule TweetProcesser.SiblingsAccesor do
  def get_sibling(parent_pid, type) do
    children = Supervisor.which_children(parent_pid)
    {_child_type, pid, _ceva, _ceva2} = children |> List.keyfind(type, 0)
    {pid}
  end
end

#{TweetProcesser.DummySupervisor, #PID<0.392.0>, :supervisor, [DynamicSupervisor]}
