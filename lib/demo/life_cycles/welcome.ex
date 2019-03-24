defmodule LifeCycles.Welcome do
  @behaviour LifeCycles.LifeCycleBehaviour
  use LifeCycle

  @impl true
  def apply(life_cycle) do
    receive do
      {pid, {:mounted, player}} ->
        :timer.sleep(1000)

        life_cycle
        |> assign(:player, player)
        |> go_to(LifeCycles.SelectHero)
    end
  end

  def mounted(player) do
    notify(player, {:mounted, player})
  end
end
