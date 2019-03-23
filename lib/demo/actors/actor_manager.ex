defmodule Actors.ActorManager do
  alias Actors.BasicActor
  alias Actors.Actors

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
  def init(state), do: {:ok, state}

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
    {:ok, actor_pid} = BasicActor.start_link(actor)
    GenServer.call(__MODULE__, {:save, actor_pid})
    actor
  end

  def all() do
    GenServer.call(__MODULE__, :all)
  end

  def handle_call({:save, actor_pid}, _, state) do
    {:reply, actor_pid, [actor_pid | state]}
  end

  def handle_call(:all, _, state) do
    {:reply, state, state}
  end

end
