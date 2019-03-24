defmodule LifeCycles.LifeCycleBehaviour do
  @callback apply(%Game.Card{}) :: :ok

end
