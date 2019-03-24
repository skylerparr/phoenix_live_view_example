defmodule LifeCycles.CardChosen do
  @behaviour LifeCycles.LifeCycleBehaviour
  use LifeCycle

  alias DemoWeb.GameLive

  require Logger

  @impl true
  def apply(life_cycle) do
    card = fetch(life_cycle, :card_chosen)
    case card.target do
      :enemy ->
        GameLive.pick_enemy_target(life_cycle)
      _ ->
        Logger.fatal("unhandled target")
    end
    receive do
    end
  end
end
