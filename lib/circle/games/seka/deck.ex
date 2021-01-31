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

  def rank(card) do
    [value, _sign] = String.split(card, "", trim: true)
    Enum.find_index(@values, &(&1 == value))
  end

  def is_win({set1, set2, set3, set4}, draw_card) do
    is_win({[draw_card | set1], set2, set3, set4}) ||
      is_win({set1, [draw_card | set2], set3, set4}) ||
      is_win({set1, set2, [draw_card | set3], set4}) ||
      is_win({set1, set2, set3, [draw_card | set4]})
  end

  def is_win(hand) do
    hand
    |> Tuple.to_list()
    |> Enum.map(
      &{
        &1 |> is_discard() |> boolean_to_integer(),
        &1 |> is_tris() |> boolean_to_integer(),
        &1 |> is_quatris() |> boolean_to_integer()
      }
    )
    |> Enum.reduce(fn {d, t, q}, {ad, at, aq} -> {d + ad, t + at, q + aq} end)
    |> Kernel.==({1, 2, 1})
  end

  def is_tris(set) do
    length(set) == 3 && (same_rank?(set) || (same_sign?(set) && consecutive?(set)))
  end

  def is_quatris(set) do
    length(set) == 4 && (same_rank?(set) || (same_sign?(set) && consecutive?(set)))
  end

  def is_draw_tris(set, draw_card), do: is_tris([draw_card | set])

  def is_draw_quatris(set, draw_card), do: is_quatris([draw_card | set])

  def is_discard(set) do
    length(set) == 1
  end

  def same_rank?(set) do
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

  def consecutive?(set) do
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

  def boolean_to_integer(true), do: 1
  def boolean_to_integer(false), do: 0

  defp dif(value1, value2), do: min(value2 - value1, 13 - value2 + value1)
end
