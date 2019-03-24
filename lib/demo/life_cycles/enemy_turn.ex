defmodule LifeCycles.EnemyTurn do
  @behaviour LifeCycles.LifeCycleBehaviour
  use LifeCycle

  @impl true
  def apply(life_cycle) do
    receive do
    end
  end
end
