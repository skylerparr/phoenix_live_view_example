defmodule LifeCycles.SelectHero do
  @behaviour LifeCycles.LifeCycleBehaviour
  use LifeCycle

  @impl true
  def apply(life_cycle) do
    receive do
      {pid, {:select_hero, name}} ->
        %{life_cycle | module: LifeCycles.StartBattle}
    end
  end

  def select_hero(hero_name) do
    notify({:select_hero, hero_name |> String.to_atom()})
  end

end
