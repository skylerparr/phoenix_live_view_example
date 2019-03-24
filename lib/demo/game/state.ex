defmodule Game.State do
  use GenServer

  @idle :idle
  @choose_card :choose_card
  @choose_enemy :choose_enemy
  @enemy_turn :enemy_turn

  def start_link(_) do
    GenServer.start_link(__MODULE__, @idle, name: __MODULE__)
  end
  def init(s), do: {:ok, s}

  def get_state() do
    GenServer.call(__MODULE__, :get)
  end

  def set_state(state) do
    GenServer.call(__MODULE__, {:set, state})
  end

  def handle_call(:get, _, state) do
    {:reply, state, state}
  end

  def handle_call({:set, state}, _, _) do
    {:reply, state, state}
  end
end
