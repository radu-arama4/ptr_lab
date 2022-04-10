defmodule TweetProcesser.SiblingsAccesor do
  def get_sibling(parent_pid, type) do
    children = Supervisor.which_children(parent_pid)

    for child <- children do
      {child_type, pid, _ceva, _ceva2} = child
      IO.puts "iteration!!"
      IO.inspect child_type
      if child_type == type do
        right_pid = pid
        {right_pid}
      end
    end
  end
end

#{TweetProcesser.DummySupervisor, #PID<0.392.0>, :supervisor, [DynamicSupervisor]}
