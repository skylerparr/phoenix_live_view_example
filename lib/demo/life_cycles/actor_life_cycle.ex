defmodule LifeCycles.ActorLifeCycle do
  alias LifeCycles.LifeCycleBehaviour
  @behaviour LifeCycleBehaviour

  @impl LifeCycleBehaviour
  def apply(card) do
    :ok
  end
end
