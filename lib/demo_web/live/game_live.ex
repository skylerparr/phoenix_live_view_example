defmodule DemoWeb.GameLive do
  use Phoenix.LiveView
  alias Actors.ActorManager
  alias Actors.BasicActor
  alias DemoWeb.Router.Helpers, as: Routes
  alias Actors.Actors
  alias Game.Card
  alias Game.CardTemplate
  alias Game.GameWorld
  alias LifeCycles.Join
  alias Accounts.PlayerManager
  alias Accounts.Player
  alias LifeCycles.SelectHero

  require Logger

  def render(%{scene: :battle} = assigns) do
    ~L"""
    <div id="game_container">
      <img src="/images<%= Routes.static_path(DemoWeb.Endpoint, "/terrain.jpg") %>" style="position:absolute"/>
      <div style="position:absolute;left:0px;top:0">
        <%= for actor <- @actors do %>
          <div style="left:<%= actor.x %>px;top:<%= actor.y %>px;width:96px;height:96px;overflow:hidden;
                transform: scaleX(<%= get_direction(actor) %>);
                position:absolute;background: url('/images<%= Routes.static_path(DemoWeb.Endpoint, actor.img) %>') left top;
                animation: <%= actor.css_anim_prefix %><%= actor.pose %> 0.5s steps(4) infinite;">
          </div>
          <div class="hp_bar" style="left:<%= actor.x %>px;top:<%= actor.y %>px;" >
            <div style="width:<%= (actor.hp / actor.max_hp) * 100 %>%; height: 100%; background-color:red;">
            </div>
          </div>
        <% end %>
      </div>
    </div>

    <div id="player_cards">
      <%= if(false) do %>
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
    """
  end

  def render(%{scene: :choose_hero} = assigns) do
    ~L"""
    <h3>Welcome, Choose your hero!</h3>
    <table>
      <tr>
        <td>
          <div class="choose_character" phx-click="select_hero_jouline">
            <img class="choose_character_image" src="/images<%= Routes.static_path(DemoWeb.Endpoint, "/free_1/Free_1_Face_640x480.png") %>" />
            <p class="choose_character_name">Jouline</p>
          </div>
        </td>
        <td>
          <div class="choose_character" phx-click="select_hero_arianna">
            <img class="choose_character_image" src="/images<%= Routes.static_path(DemoWeb.Endpoint, "/free_6/Free_6_Bust.png") %>" />
            <p class="choose_character_name">Arianna</p>
          </div>
        </td>
        <td>
          <div class="choose_character" phx-click="select_hero_surge">
            <img class="choose_character_image" src="/images<%= Routes.static_path(DemoWeb.Endpoint, "/free_8/Free_8_Bust.png") %>" />
            <p class="choose_character_name">Surge</p>
          </div>
        </td>
      </tr>
    </table>
    """
  end

  def render(assigns) do
    ~L"""
    <h3>Welcome to Working Title</h3>
    """
  end

  def mount(_session, %{id: id} = socket) do
    if(PlayerManager.get_player_by_session_id(id) == nil) do
      {:ok, life_cycle_pid} = LifeCycle.start_link()
      player = PlayerManager.add_player(self(), %Player{id: Ecto.UUID.generate(), session_id: id, life_cycle_pid: life_cycle_pid})
    else
      case PlayerManager.get_player_by_session_pid(self()) do
        nil ->
          nil
        player ->
          LifeCycle.stop(player.life_cycle_pid)
          PlayerManager.remove_player(self())
      end
      Logger.debug("mounting and starting lifecycle")
      {:ok, life_cycle_pid} = LifeCycle.start_link()
      :timer.sleep(10)
      player = PlayerManager.add_player(self(), %Player{id: Ecto.UUID.generate(), session_id: id, life_cycle_pid: life_cycle_pid})
      LifeCycles.Welcome.mounted(player)
    end

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

  def update_screen(%{assigns: %{life_cycle: %{assigns: assigns}}} = socket) do
    %{heroes: heroes, enemies: enemies} = assigns
    actors = heroes ++ enemies

    socket
    |> assign(:actors, actors)
  end

  def update_screen(socket) do
    socket
  end

  def restart() do
    ActorManager.restart()
  end

  def choose_hero(player) do
    send(player.session_pid, :choose_hero)
  end

  def start_battle(%{assigns: %{player: player}} = life_cycle) do
    send(player.session_pid, {:start_battle, life_cycle})
  end

  def handle_info(:render, socket) do
    {:noreply, socket |> update_screen()}
  end

  def handle_info(:choose_hero, socket) do
    Logger.debug("render choose hero")
    {
      :noreply,
      socket
      |> assign(:scene, :choose_hero)
      |> update_screen()
    }
  end

  def handle_info({:start_battle, life_cycle}, socket) do
    Logger.debug("render start battle")
    {
      :noreply,
      socket
      |> assign(:scene, :battle)
      |> assign(:life_cycle, life_cycle)
      |> update_screen()
    }
  end

  def handle_event("on_card_click_" <> id, _, socket) do
    GameWorld.play_card(id)
    {:noreply, socket}
  end

  def handle_event("start_game", _, socket) do
    LifeCycles.Join.start_game()
    {:noreply, socket}
  end

  def handle_event("select_hero_" <> hero_name, _, socket) do
    Logger.debug("Selecting hero #{inspect(hero_name)}")
    SelectHero.select_hero(hero_name)
    {:noreply, socket}
  end

#  def terminate(_, state) do
#    Logger.debug("terminating session")
#    case PlayerManager.get_player_by_session_pid(self()) do
#      nil ->
#        nil
#      player ->
#        LifeCycle.stop(player.life_cycle_pid)
#        PlayerManager.remove_player(self())
#    end
#
#    {:noreply, state}
#  end

  def get_direction(actor) do
    case actor.team do
      :left -> -1
      :right -> 1
    end
  end
end
