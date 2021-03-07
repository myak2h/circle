defmodule Circle.Games.Seka.Deck do
  @sign ["H", "D", "S", "F"]
  @values ["A", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K"]
  @jocker "JO"

  def cards(opts \\ []) do
    decks = opts[:decks] || 1
    jockers = (opts[:jockers] || 2) * decks

    for value <- @values, sign <- @sign do
      "#{value}#{sign}"
    end
    |> List.duplicate(decks)
    |> List.flatten()
    |> Kernel.++(List.duplicate(@jocker, jockers))
    |> Enum.shuffle()
  end

  def value(card) do
    [value, _sign] = String.split(card, "", trim: true)
    value
  end

  def sign(card) do
    [_value, sign] = String.split(card, "", trim: true)
    sign
  end

  def rank("JO"), do: 13

  def rank(card) do
    [value, _sign] = String.split(card, "", trim: true)
    Enum.find_index(@values, &(&1 == value))
  end

  def is_win(hand) do
    {tris1, other} = Enum.split(hand, 3)
    {tris2, other} = Enum.split(other, 3)
    {quatris, _discard} = Enum.split(other, 4)
    is_tris(tris1) && is_tris(tris2) && is_quatris(quatris)
  end

  defp is_tris(set) do
    length(set) == 3 && (same_rank?(set) || (same_sign?(set) && consecutive?(set)))
  end

  defp is_quatris(set) do
    length(set) == 4 && (same_rank?(set) || (same_sign?(set) && consecutive?(set)))
  end

  defp same_rank?(set) do
    set
    |> Enum.filter(&(&1 != "JO"))
    |> Enum.map(&value/1)
    |> Enum.uniq()
    |> length()
    |> Kernel.==(1)
  end

  defp same_sign?(set) do
    set
    |> Enum.filter(&(&1 != "JO"))
    |> Enum.map(&sign/1)
    |> Enum.uniq()
    |> length()
    |> Kernel.==(1)
  end

  defp consecutive?(set) do
    {jockers, non_jockers} = Enum.split_with(set, &(&1 == "JO"))

    non_jocker_ranks =
      non_jockers
      |> Enum.map(&rank/1)
      |> Enum.sort()

    if non_jocker_ranks == Enum.uniq(non_jocker_ranks) do
      preceder = non_jocker_ranks |> Enum.reverse() |> tl() |> Enum.reverse()
      follower = tl(non_jocker_ranks)

      preceder
      |> Enum.zip(follower)
      |> Enum.reduce(0, fn {p, f}, acc -> acc + dif(p, f) - 1 end)
      |> Kernel.<=(length(jockers))
    else
      false
    end
  end

  defp dif(value1, value2), do: min(value2 - value1, 13 - value2 + value1)
end
