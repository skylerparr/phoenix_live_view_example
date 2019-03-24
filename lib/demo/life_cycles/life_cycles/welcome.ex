defmodule LifeCycles.Welcome do
  @behaviour LifeCycles.LifeCycleBehaviour
  use LifeCycle

  @impl true
  def apply(life_cycle) do
    receive do
      {pid, :mounted} ->
        :timer.sleep(1000)
        go_to(life_cycle, LifeCycles.SelectHero)
    end
  end

  def mounted() do
    notify(:mounted)
  end
end
