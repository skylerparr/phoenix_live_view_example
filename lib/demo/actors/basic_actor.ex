defmodule Actors.BasicActor do
  defstruct id: nil,
            pose: nil,
            img: nil,
            actor_pid: nil,
            css_anim_prefix: "",
            imgX: 0,
            imgY: 0,
            team: :right,
            x: 0,
            y: 0,
            targetX: 0,
            targetY: 0,
            gold: 0,
            hp: 0,
            max_hp: 0,
            energy: 0,
            max_energy: 0,
            block: 0,
            play_pile: [],
            draw_pile: [],
            discard_pile: [],
            exhausted: []

  use GenServer

  alias Game.GameWorld

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

  def kill(actor_pid) do
    GenServer.call(actor_pid, :kill)
  end

  def update_play_pile(%{play_pile: play_pile, actor_pid: actor_pid} = actor, card) do
    card_to_delete = Enum.find(play_pile, fn(%{id: id}) -> id == card.id end)
    play_pile = List.delete(play_pile, card_to_delete)
    play_pile = [card | play_pile]
    actor = %{actor | play_pile: play_pile}
    GenServer.cast(actor_pid, {:update_actor, actor})
  end

  def handle_call(:get, _, actor), do: {:reply, actor, actor}

  def handle_call(:kill, _, actor) do
    actor = %{actor | pose: :dead}
    game_world_pid = GameWorld.get_game_world()
    send(game_world_pid, :render)
    {:reply, actor, actor}
  end

  def handle_cast({:update_actor, actor}, _) do
    Process.send_after(GameWorld.get_game_world(), :render, 100)
    {:noreply, actor}
  end

  def handle_cast({:set_pose, pose}, actor) do
    actor = %{actor | pose: pose}
    game_world_pid = GameWorld.get_game_world()
    send(game_world_pid, :render)
    Process.send_after(actor.actor_pid, :reset_to_idle, 120 * 4)
    {:noreply, actor}
  end

  def handle_info(:reset_to_idle, actor) do
    actor = %{actor | pose: :idle}
    send(GameWorld.get_game_world(), :render)
    {:noreply, actor}
  end

  def terminate(:normal, _state) do
    :ok
  end

end
