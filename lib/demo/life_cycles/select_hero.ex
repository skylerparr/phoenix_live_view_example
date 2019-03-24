defmodule LifeCycles.SelectHero do
  @behaviour LifeCycles.LifeCycleBehaviour
  use LifeCycle

  @impl true
  def apply(%{assigns: %{player: player}} = life_cycle) do
    DemoWeb.GameLive.choose_hero(player)
    receive do
      {pid, {:select_hero, name}} ->
        %{life_cycle | module: LifeCycles.StartBattle}
    end
  end

  def select_hero(hero_name) do
    notify({:select_hero, hero_name |> String.to_atom()})
  end

end
