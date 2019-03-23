defmodule Actors.BasicActor do
  defstruct id: nil,
            pose: nil,
            frame: 0,
            img: nil,
            pid: nil,
            imgX: 0,
            imgY: 0,
            reverse: false,
            x: 0,
            y: 0,
            targetX: 0,
            targetY: 0

  use GenServer

  alias Actors.Actors

  @update 120

  def start_link(actor) do
    GenServer.start_link(__MODULE__, actor)
  end

  def init(a) do
    Process.send_after(self(), :update, @update)
    {:ok, a}
  end

  def handle_info(:update, actor) do
    actor = case actor.reverse do
      true -> Map.put(actor, :frame, actor.frame - 1)
      false -> Map.put(actor, :frame, actor.frame + 1)
    end

    actor = cond do
      actor.frame >= 4 && !actor.reverse ->
        Map.put(actor, :frame, 0)
      actor.frame <= -1 && actor.reverse  ->
        Map.put(actor, :frame, 3)
      true ->
        actor
    end

    {x, y} = Map.get(Actors.frames(), actor.pose)
             |> Enum.at(actor.frame)

    actor =
      actor
      |> Map.put(:imgX, x)
      |> Map.put(:imgY, y)
      |> Map.put(:pose, :idle)

    send(actor.pid, {:update, actor})
    Process.send_after(self(), :update, @update)
    {:noreply, actor}
  end

end
