defmodule LifeCycle do
  defstruct module: LifeCycles.Welcome, assigns: %{}

  use GenServer

  require Logger

  defmacro __using__(_) do
    quote do
      require Logger

      def assign(life_cycle, key, value) do
        assigns = life_cycle.assigns
        assigns = Map.put(assigns, key, value)
        %{life_cycle | assigns: assigns}
      end

      def fetch(life_cycle, key, default \\ nil) do
        Map.get(life_cycle.assigns, key, default)
      end

      def go_to(life_cycle, module) do
        Logger.debug("going to module #{inspect(module)}")
        %{life_cycle | module: module}
      end

      def notify(%{life_cycle_pid: life_cycle_pid}, payload) do
        Logger.debug("notifying")
        send(life_cycle_pid, {self(), payload})
      end

      def notify(payload) do
        case Accounts.PlayerManager.get_player_by_session_pid(self()) do
          nil ->
            raise "player not found"

          player ->
            notify(player, payload)
        end
      end
    end
  end

  def start_link() do
    Logger.debug("starting lifecycle")
    GenServer.start_link(__MODULE__, %LifeCycle{})
  end

  @impl true
  def init(s) do
    Logger.debug("init")
    Process.send_after(self(), :game_loop, 10)
    {:ok, s}
  end

  def stop(pid) do
    Logger.debug("Stopping life cycle")
    Logger.debug("Process #{inspect(pid)} alive? #{Process.alive?(pid) |> inspect}")
    IO.inspect(Process.exit(pid, :kill), label: "status of exiting process")
    IO.inspect(pid, label: "pid that should be dead")
    Logger.debug("Process alive? #{Process.alive?(pid) |> inspect}")
  end

  @impl true
  def handle_info(:game_loop, state) do
    Logger.info("Switching to life cycle #{inspect(state.module)}")
    state = apply(state.module, :apply, [state])
    Process.send_after(self(), :game_loop, 100)
    {:noreply, state}
  end
end
