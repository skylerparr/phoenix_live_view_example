defmodule Accounts.PlayerManager do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, {%{}, %{}}, name: __MODULE__)
  end

  def init(s) do
    {:ok, s}
  end

  def add_player(session_pid, player) do
    player = %{player | session_pid: session_pid}
    GenServer.call(__MODULE__, {:add_player, session_pid, player})
  end

  def remove_player(session_pid) do
    GenServer.call(__MODULE__, {:remove_player, session_pid})
  end

  def handle_call({:add_player, session_pid, player}, _, {map_by_id, map_by_session}) do
    map_by_id = Map.put(map_by_id, player.id, player)
    map_by_session = Map.put(map_by_session, session_pid, player)
    {:reply, player, {map_by_id, map_by_session}}
  end

  def handle_call({:remove_player, session_pid}, _, {map_by_id, map_by_session}) do
    player = Map.get(map_by_session, session_pid)
    map_by_id = Map.delete(map_by_id, player.id)
    map_by_session = Map.delete(map_by_session, session_pid)
    {:reply, :removed, {map_by_id, map_by_session}}
  end

end
