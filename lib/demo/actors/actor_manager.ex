defmodule Actors.ActorManager do
  alias Actors.BasicActor
  alias Actors.Actors

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
  def init(state), do: {:ok, state}

  def create(actor) do
    {:ok, actor_pid} = BasicActor.start_link(actor)
    GenServer.call(__MODULE__, {:save, actor_pid})
    BasicActor.get(actor_pid)
  end

  def all() do
    GenServer.call(__MODULE__, :all)
  end

  def restart() do
    all()
    |> Enum.each(fn(actor_pid) ->
      GenServer.stop(actor_pid)
    end)
    GenServer.call(__MODULE__, :restart)
    send(Game.GameWorld.get_game_world(), :render)
  end

  def kill(actor_pid) do
    BasicActor.kill(actor_pid)
  end

  def killall() do
    all()
    |> Enum.each(fn(actor_pid) ->
      kill(actor_pid)
    end)
  end

  def handle_call({:save, actor_pid}, _, state) do
    {:reply, actor_pid, [actor_pid | state]}
  end

  def handle_call(:all, _, state) do
    {:reply, state, state}
  end

  def handle_call({:kill, actor_pid}, _, state) do
    BasicActor.kill(actor_pid)
    {:reply, state, state}
  end

  def handle_call(:restart, _, _) do
    {:reply, [], []}
  end

end
