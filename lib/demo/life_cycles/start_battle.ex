defmodule LifeCycles.StartBattle do
  @behaviour LifeCycles.LifeCycleBehaviour
  use LifeCycle

  @impl true
  def apply(life_cycle) do
    %{life_cycle | module: LifeCycles.PlayerTurn}
  end

end
