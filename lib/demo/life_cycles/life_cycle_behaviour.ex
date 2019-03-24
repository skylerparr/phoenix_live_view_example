defmodule LifeCycles.LifeCycleBehaviour do
  @callback apply(%LifeCycle{}) :: %LifeCycle{}

end
