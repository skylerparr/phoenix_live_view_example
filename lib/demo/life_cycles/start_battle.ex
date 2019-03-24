defmodule LifeCycles.StartBattle do
  @behaviour LifeCycles.LifeCycleBehaviour
  use LifeCycle

  alias DemoWeb.GameLive

  @impl true
  def apply(%{assigns: %{player: player}} = life_cycle) do
    GameLive.start_battle(life_cycle)
    %{life_cycle | module: LifeCycles.PlayerTurn}
  end
end
