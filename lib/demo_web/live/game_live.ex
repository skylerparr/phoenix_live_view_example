defmodule DemoWeb.GameLive do
  use Phoenix.LiveView
  alias Actors.ActorManager
  alias DemoWeb.Router.Helpers, as: Routes

  @tick 16

  def render(assigns) do
    ~L"""

    <img src="/images<%= Routes.static_path(DemoWeb.Endpoint, "/terrain.jpg") %>" />
    <%= for {_id, actor} <- @actors do %>
      <div style="left:<%= actor.x %>px;top:<%= actor.y %>px;width:96px;height:96px;overflow:hidden;position:absolute;">
        <img src="/images/<%= Routes.static_path(DemoWeb.Endpoint, actor.img) %>"
          style="position:absolute;left:<%= actor.imgX %>px;top:<%= actor.imgY %>px"
        />
      </div>
    <% end %>
    <a href="#" phx-click="onclick">click me</a>
    """
  end

  def mount(_session, socket) do
    {
      :ok,
      socket
      |> schedule_tick()
      |> set_defaults()
    }
  end

  def set_defaults(socket) do
    default_actor = ActorManager.create(:arianna, self())
    units = socket.assigns || %{}
    units = Map.put(units, default_actor.id, default_actor)

    socket |> assign(:actors, units)
  end

  def schedule_tick(socket) do
    Process.send_after(self(), :tick, @tick)
    socket
  end

  def handle_info(:tick, socket) do
    {
      :noreply,
      socket
      |> schedule_tick()
    }
  end

  def handle_info({:update, actor}, socket) do
    actors = socket.assigns.actors
    actors = Map.put(actors, actor.id, actor)
    socket = socket |> assign(:actors, actors)
    {:noreply, socket}
  end

  def handle_event("onclick", _, socket) do
    new_actor = ActorManager.create(:jouline, self(), :rand.uniform(1200), :rand.uniform(1200))

    actors = socket.assigns.actors
    actors = Map.put(actors, new_actor.id, new_actor)

    socket = socket |> assign(:actors, actors)
    {:noreply, socket}
  end
end
