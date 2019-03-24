defmodule LifeCycles.PlayerTurn do
  @behaviour LifeCycles.LifeCycleBehaviour
  use LifeCycle

  alias DemoWeb.GameLive

  @impl true
  def apply(life_cycle) do
    actor_turn =
      fetch(life_cycle, :actor_turn)
      |> draw_cards()
    life_cycle =
      life_cycle
      |> assign(:actor_turn, actor_turn)
      |> GameLive.choose_card()

    receive do
      {:card_chosen, card} ->
        life_cycle =
          life_cycle
          |> assign(:card_chosen, card)
        %{life_cycle | module: LifeCycles.CardChosen}
    end
  end

  def card_chosen(card) do
    notify({:card_chosen, card})
  end

  def draw_cards(%{draw_pile: draw_pile, play_pile: play_pile, discard_pile: discard_pile} = actor) do
    discard_pile = List.flatten(play_pile ++ discard_pile)
    play_pile = []
    {card, draw_pile} = List.pop_at(draw_pile, 0)
    play_pile = [card | play_pile]

    %{actor | draw_pile: draw_pile, play_pile: play_pile, discard_pile: discard_pile}
  end
end
