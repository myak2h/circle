defmodule Circle.Games.Seka.Player do
  @derive Jason.Encoder
  defstruct id: "1", hand: %{0 => [], 1 => [], 2 => [], 3 => []}, index: 0, name: nil

  def parse(player) do
    %__MODULE__{
      id: player["id"],
      hand: parse_hand(player["hand"]),
      index: player["index"],
      name: player["name"]
    }
  end

  defp parse_hand(hand) do
    %{0 => hand["0"], 1 => hand["1"], 2 => hand["2"], 3 => hand["3"]}
  end
end
