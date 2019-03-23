defmodule Actors.ActorManager do
  alias Actors.BasicActor
  alias Actors.Actors

  def create(name, pid, x \\ 0, y \\ 0) do
    actor = %BasicActor{
      id: Ecto.UUID.generate(),
      pose: :idle,
      frame: 0,
      img: apply(Actors, name, []),
      pid: pid,
      x: x,
      y: y
    }
    BasicActor.start_link(actor)
    actor
  end

end
