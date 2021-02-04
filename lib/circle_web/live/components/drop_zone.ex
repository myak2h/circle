defmodule CircleWeb.Live.Components.DropZone do
  use Phoenix.LiveComponent
  alias CircleWeb.SekaLive

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
      <p>👤 - You</p>
      <div id="<%= @drop_zone_id %>" phx-hook="Drag" style="display: flex; flex-flow: row;">
        <%= for {card, index} <- Enum.with_index(@cards) do %>
          <button
            draggable="true"
            class="draggable"
            id="<%= @player_id %>-card-<%= index %>"
            style="padding: 5px; margin: 5px; font-size: 20px"
            phx-click="discard"
            phx-value-card="<%= card %>"
            >
            <%= SekaLive.card(card) %>
          </button>
        <% end %>
      </div>
    """
  end
end
