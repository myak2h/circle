defmodule CircleWeb.Live.Components.GameLink do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div>
      <label>Share the game link to add players: </label>
      <input value="<%= @link %>" readonly id="game-link"/>
      <button phx-hook="CopyToClipboard"><i class="fas fa-clipboard"></i></button>
    </div>
    """
  end
end
