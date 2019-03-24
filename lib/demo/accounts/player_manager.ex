defmodule Accounts.PlayerManager do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, {%{}, %{}, %{}}, name: __MODULE__)
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

  def get_player_by_session_pid(session_pid) do
    GenServer.call(__MODULE__, {:get_player_by_session_pid, session_pid})
  end

  def get_player_by_session_id(session_id) do
    GenServer.call(__MODULE__, {:get_player_by_session_id, session_id})
  end

  def handle_call({:add_player, session_pid, player}, _, {map_by_id, map_by_session_pid, by_session_id}) do
    map_by_id = Map.put(map_by_id, player.id, player)
    map_by_session = Map.put(map_by_session_pid, session_pid, player)
    by_session_id = Map.put(by_session_id, player.session_id, player)
    {:reply, player, {map_by_id, map_by_session, by_session_id}}
  end

  def handle_call({:remove_player, session_pid}, _, {map_by_id, map_by_session_pid, by_session_id}) do
    player = Map.get(map_by_session_pid, session_pid)
    map_by_id = Map.delete(map_by_id, player.id)
    map_by_session = Map.delete(map_by_session_pid, session_pid)
    by_session_id = Map.put(by_session_id, player.session_id, player)
    {:reply, :removed, {map_by_id, map_by_session, by_session_id}}
  end

  def handle_call({:get_player_by_session_pid, session_pid}, _, {_map_by_id, map_by_session, _by_session_id} = state) do
    {:reply, Map.get(map_by_session, session_pid), state}
  end

  def handle_call({:get_player_by_session_id, session_id}, _, {_map_by_id, _map_by_session, by_session_id} = state) do
    {:reply, Map.get(by_session_id, session_id), state}
  end

end
