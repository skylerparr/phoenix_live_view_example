defmodule DemoWeb.GameLive do
  use Phoenix.LiveView
  alias Actors.ActorManager
  alias Actors.BasicActor
  alias DemoWeb.Router.Helpers, as: Routes

  @tick 16

  def render(assigns) do
    ~L"""
    <div id="game_container">
      <img src="/images<%= Routes.static_path(DemoWeb.Endpoint, "/terrain.jpg") %>" style="position:absolute"/>
      <div style="position:absolute;left:0px;top:0">
        <%= for {_id, actor} <- @actors do %>
          <div style="left:<%= actor.x %>px;top:<%= actor.y %>px;width:96px;height:96px;overflow:hidden;
                position:absolute;background: url('/images/<%= Routes.static_path(DemoWeb.Endpoint, actor.img) %>') left top;
                animation: <%= actor.pose %> 0.4s steps(4) infinite;">
          </div>
        <% end %>

      </div>
    </div>
    <a href="#" phx-click="onclick" style="position:absolute;top:0px;left:0px">click me</a>
    """
  end

  def mount(_session, socket) do
    {
      :ok,
      socket
      |> update_screen()
    }
  end

  def update_screen(socket) do
    actors = ActorManager.all()
    |> Enum.reduce(%{}, fn(pid, acc) ->
      actor = BasicActor.get(pid)
      case actor == nil do
        true -> acc
        false -> Map.put(acc, actor.id, actor)
      end
    end)

    socket |> assign(:actors, actors)
  end

  def handle_info(:update_actors, socket) do
    {:noreply, socket |> update_screen()}
  end

  def handle_event("onclick", _, socket) do
    new_actor = ActorManager.create(:jouline, self(), :rand.uniform(800), :rand.uniform(800))

    actors = socket.assigns.actors
    actors = Map.put(actors, new_actor.id, new_actor)

    socket = socket |> assign(:actors, actors)
    {:noreply, socket}
  end
end
