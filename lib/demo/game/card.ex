defmodule Game.Card do
  defstruct template: nil,
            id: nil,
            energy_cost: 0,
            upgraded: false,
            affected: [],
            affects: []
end
