defmodule Game.GameWorld do
  use GenServer

  alias __MODULE__
  alias Game.Card
  alias Actors.BasicActor

  defstruct current_actor_turn: nil

  def get_game_world() do
    Process.whereis(:game_world)
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  def init(s), do: {:ok, s}

  def get_current_actor_turn() do
    GenServer.call(__MODULE__, :get_current_actor_turn)
  end

  def set_current_actor_turn(actor) do
    GenServer.call(__MODULE__, {:set_current_actor_turn, actor})
  end

  def play_card(card_id) do
    actor = get_current_actor_turn()
    card = get_card(actor.play_pile, card_id)
    apply_card(actor, card)
  end

  defp get_card(cards, id) do
    Enum.find(cards, fn card -> card.id == id end)
  end

  def apply_card(actor, %Card{template: %{target: :enemy}} = card) do
    card = %{card | css_class: :card_center}
    BasicActor.update_play_pile(actor, card)
  end

  def apply_card(actor, %Card{template: %{target: :ally}} = card) do
  end

  def apply_card(actor, %Card{template: %{target: :card}} = card) do
  end

  def apply_card(actor, %Card{template: %{target: :self}} = card) do
  end

  def apply_card(actor, %Card{template: %{target: :all_allies}} = card) do
  end

  def apply_card(actor, %Card{template: %{target: :all_cards}} = card) do
  end

  def apply_card(actor, %Card{template: %{target: :all_enemies}} = card) do
  end

  def handle_call(:get_current_actor_turn, _, state) do
    {:reply, state.current_actor_turn || %{id: nil}, state}
  end

  def handle_call({:set_current_actor_turn, actor}, _, state) do
    state = %{state | current_actor_turn: actor}
    {:reply, state.current_actor_turn, state}
  end
end
