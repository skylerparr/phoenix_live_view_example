defmodule LifeCycles.SelectHero do
  @behaviour LifeCycles.LifeCycleBehaviour
  use LifeCycle

  alias Actors.BasicActor
  alias Game.Card
  alias Game.CardTemplate
  alias Actors.Actors

  @impl true
  def apply(%{assigns: %{player: player}} = life_cycle) do
    DemoWeb.GameLive.choose_hero(player)
    receive do
      {pid, {:select_hero, name}} ->
        hero = load_hero(player, name)
        life_cycle = assign(life_cycle, :heroes, [hero])
        enemy = load_enemy(:lizard)
        life_cycle = assign(life_cycle, :enemies, [enemy])
        %{life_cycle | module: LifeCycles.StartBattle}
    end
  end

  def select_hero(hero_name) do
    Logger.debug("selecting hero #{hero_name}")
    notify({:select_hero, hero_name |> String.to_atom()})
  end

  def load_hero(_player, hero) do
    generate_cards(hero)
  end

  defp generate_cards(hero) do
    template = %CardTemplate{
      type: :hero,
      usage_type: :attack,
      title: "Back Stab",
      description: "Deal 5 damage to an enemy",
      image: "",
      energy_cost: 1,
      innate: false,
      exhaust: false,
      target: :enemy,
      affects: [{:damage, 5}]
    }

    cards = [
      %Card{
        template: template,
        id: Ecto.UUID.generate(),
        energy_cost: template.energy_cost,
        upgraded: false,
        affects: template.affects
      }
    ]

    actor = %BasicActor{
      id: Ecto.UUID.generate(),
      pose: :idle,
      team: :left,
      img: apply(Actors, hero, []),
      x: 200,
      y: 100,
      gold: 0,
      hp: 100,
      max_hp: 100,
      energy: 3,
      max_energy: 3,
      block: 0,
      play_pile: [],
      draw_pile: cards,
      discard_pile: [],
      exhausted: []
    }
    {:ok, actor_pid} = BasicActor.start_link(actor)
    %{actor | actor_pid: actor_pid}
  end

  def load_enemy(name) do
    actor = %BasicActor{
      id: Ecto.UUID.generate(),
      pose: :idle,
      team: :right,
      img: apply(Actors, name, []),
      css_anim_prefix: "lizard_",
      x: 800,
      y: 100,
      gold: 0,
      hp: 100,
      max_hp: 100,
      energy: 3,
      max_energy: 3,
      block: 0,
      play_pile: [],
      draw_pile: [],
      discard_pile: [],
      exhausted: []
    }
    {:ok, actor_pid} = BasicActor.start_link(actor)
    %{actor | actor_pid: actor_pid}
  end
end
