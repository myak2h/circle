defmodule CircleWeb.Live.Components.Seka.GameRule do
  use Phoenix.LiveComponent

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
      <h1>How to play the game ?</h1>
      <ol style="font-size: 20px">
        <li>You can <b>draw</b> a card by clicking on either the <b>closed deck</b> or the <b>discard pile</b> in the middle.</li>
        <li>You can <b>discard</b> a card by clicking on one of the cards in your hand.</li>
        <li>The purpose of the game is to build <b>two trises</b> and <b>a quatris</b>.</li>
        <li>a <b>tris</b> is a set of <b>3</b> cards of either the same number and different sign or consecutive number and the same sign. a <b>quatris</b> is similar to a tris but with <b>4</b> cards.</li>
        <li>Use the <b>Sort</b> button to sort the cards</li>
        <li>After putting the trises and the quatris under their respectve label, use the <b>Declare</b> button to finish the game.</li>
      </ol>
    """
  end
end
