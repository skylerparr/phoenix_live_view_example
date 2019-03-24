defmodule Game.CardTemplate do
  defstruct type: nil,
            usage_type: nil,
            title: nil,
            description: nil,
            image: nil,
            energy_cost: 0,
            innate: false,
            exhaust: false,
            target: nil,
            affects: [],
            up_engergy_cost: 0,
            up_innate: false,
            up_exhaust: false,
            up_targets: nil,
            up_affects: []

  def usage_types() do
    [:attack, :skill, :power]
  end

  def affects() do
    [:self, :ally, :all_allies, :card, :all_cards, :enemy, :all_enemies]
  end
end
