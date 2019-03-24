defmodule LifeCycles.StartGame do
  @behaviour LifeCycles.LifeCycleBehaviour
  use LifeCycle

  @impl true
  def apply(life_cycle) do
    %{life_cycle | module: LifeCycles.StartBattle}
  end
end
