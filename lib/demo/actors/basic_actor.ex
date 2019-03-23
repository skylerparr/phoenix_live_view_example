defmodule Actors.BasicActor do
  defstruct id: nil,
            pose: nil,
            frame: 0,
            img: nil,
            pid: nil,
            actor_pid: nil,
            imgX: 0,
            imgY: 0,
            reverse: false,
            x: 0,
            y: 0,
            targetX: 0,
            targetY: 0

  use GenServer

  alias Actors.Actors

  def start_link(actor) do
    GenServer.start(__MODULE__, actor)
  end

  def init(a) do
    a = %{a | actor_pid: self()}
    {:ok, a}
  end

  def get(actor_pid) do
    if(Process.alive?(actor_pid)) do
      GenServer.call(actor_pid, :get)
    end
  end

  def set_pose(actor, pose) do
    GenServer.cast(actor.actor_pid, {:set_pose, pose})
  end

  def handle_call(:get, _, actor), do: {:reply, actor, actor}

  def handle_cast({:set_pose, pose}, actor) do
    actor = %{actor | pose: pose}
    send(actor.pid, :update_actors)
    Process.send_after(actor.actor_pid, :reset_to_idle, 120 * 4)
    {:noreply, actor}
  end

  def handle_info(:reset_to_idle, actor) do
    actor = %{actor | pose: :idle}
    send(actor.pid, :update_actors)
    {:noreply, actor}
  end

end
