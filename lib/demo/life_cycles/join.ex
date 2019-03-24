defmodule LifeCycles.Join do
  @behaviour LifeCycles.LifeCycleBehaviour

  use LifeCycle

  @impl true
  def apply(life_cycle) do
    receive do
      {pid, {:player_joined, actor}} ->
        players = fetch(life_cycle, :players, [])
        players = [actor | players]
        assign(life_cycle, :players, players)
      {pid, :start_game} ->
        %{life_cycle | module: LifeCycles.SelectHero}
    end
  end

  def player_join(actor) do
    notify({:player_joined, actor})
  end

  def start_game() do
    notify(:start_game)
  end

end
