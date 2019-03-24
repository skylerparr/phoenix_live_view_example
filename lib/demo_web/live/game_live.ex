defmodule DemoWeb.GameLive do
  use Phoenix.LiveView
  alias Actors.ActorManager
  alias Actors.BasicActor
  alias DemoWeb.Router.Helpers, as: Routes
  alias Actors.Actors
  alias Game.Card
  alias Game.CardTemplate
  alias Game.GameWorld

  def render(assigns) do
    ~L"""
    <div id="game_container">
      <img src="/images<%= Routes.static_path(DemoWeb.Endpoint, "/terrain.jpg") %>" style="position:absolute"/>
      <div style="position:absolute;left:0px;top:0">
        <%= for {_id, actor} <- @actors do %>
          <div style="left:<%= actor.x %>px;top:<%= actor.y %>px;width:96px;height:96px;overflow:hidden;
                transform: scaleX(<%= get_direction(actor) %>);
                position:absolute;background: url('/images<%= Routes.static_path(DemoWeb.Endpoint, actor.img) %>') left top;
                animation: <%= actor.pose %> 0.4s steps(4) infinite;">
          </div>
          <div class="hp_bar" style="left:<%= actor.x %>px;top:<%= actor.y %>px;" >
            <div style="width:<%= (actor.hp / actor.max_hp) * 100 %>%; height: 100%; background-color:red;"
          </div>
        <% end %>
      </div>
    </div>

      <div id="player_cards">
        <%= if(@you.id == GameWorld.get_current_actor_turn().id) do %>
          <%= for card <- @you.play_pile do %>
            <div style="background: url('/images<%= Routes.static_path(DemoWeb.Endpoint, "/cards/empty.png") %>') no-repeat;"
                class="<%= card.css_class %>"
                phx-click="on_card_click_<%= card.id %>">
              <p class="card_energy_cost"><%= card.energy_cost %></p>
              <p class="card_title"><%= card.template.title %></p>
              <p class="card_type"><%= card.template.usage_type %></p>
              <p class="card_description"><%= card.template.description %></p>
            </div>
          <% end %>
        <% end %>
      </div>
    <a href="#" phx-click="join" style="position:absolute;top:0px;left:0px">join</a>
    """
  end

  def mount(session, socket) do
    case Process.whereis(:game_world) do
      nil -> nil
      _pid -> Process.unregister(:game_world)
    end
    Process.register(self(), :game_world)
    {
      :ok,
      socket
      |> update_screen()
    }
  end

  def update_screen(socket) do
    you = Map.get(socket.assigns, :you, %{id: ""})

    actors = ActorManager.all()
    |> Enum.reduce(%{}, fn(pid, acc) ->
      actor = BasicActor.get(pid)
      case actor == nil do
        true -> acc
        false -> Map.put(acc, actor.id, actor)
      end
    end)

    {_, you} = Enum.find(actors, fn({id, _}) -> you.id == id end) || {"", %{id: ""}}

    socket
    |> assign(:actors, actors)
    |> assign(:you, you)
  end

  def restart() do
    ActorManager.restart()
  end

  def handle_info(:render, socket) do
    {:noreply, socket |> update_screen()}
  end

  def handle_event("on_card_click_" <> id, _, socket) do
    GameWorld.play_card(id)
    {:noreply, socket}
  end

  def handle_event("join", _, socket) do
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
      img: apply(Actors, :arianna, []),
      x: 200,
      y: 100,
      gold: 0,
      hp: 100,
      max_hp: 100,
      energy: 3,
      max_energy: 3,
      block: 0,
      play_pile: cards,
      draw_pile: [],
      discard_pile: [],
      exhausted: []
    }
    new_actor = ActorManager.create(actor)
    GameWorld.set_current_actor_turn(new_actor)

    actors = socket.assigns.actors
    actors = Map.put(actors, new_actor.id, new_actor)

    socket = socket
             |> assign(:actors, actors)
             |> assign(:you, new_actor)
    {:noreply, socket}
  end

  def get_direction(actor) do
    case actor.team do
      :left -> -1
      :right -> 1
    end
  end
end
