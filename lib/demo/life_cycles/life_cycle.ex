defmodule LifeCycle do
  defstruct module: LifeCycles.Welcome, assigns: %{}

  use GenServer

  require Logger

  defmacro __using__(_) do
    quote do
      def assign(life_cycle, key, value) do
        assigns = life_cycle.assigns
        assigns = Map.put(assigns, key, value)
        %{life_cycle | assigns: assigns}
      end

      def fetch(life_cycle, key, default \\ nil) do
        assigns = life_cycle.assigns
        Map.get(life_cycle, key, default)
      end

      def go_to(life_cycle, module) do
        %{life_cycle | module: module}
      end

      def notify(payload) do
        pid = Process.whereis(LifeCycle)
        send(pid, {self(), payload})
      end
    end
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, %LifeCycle{}, name: __MODULE__)
  end
  
  @impl true
  def init(s) do
    Process.send_after(self(), :game_loop, 1000)
    {:ok, s}
  end

  @impl true
  def handle_info(:game_loop, state) do
    IO.inspect state
    Logger.info("Switching to life cycle #{inspect(state.module)}")
    state = apply(state.module, :apply, [state])
    Process.send_after(self(), :game_loop, 100)
    {:noreply, state}
  end

end
