defmodule CircleWeb.Live.Components.DropZone do
  use Phoenix.LiveComponent
  import Phoenix.HTML.Tag
  alias CircleWeb.SekaLive

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""

      <div>
        👤 - <%= @player_name %>
        <%= if @game_status != :won do %>
          <button style="padding: 5px; margin-left: 10px" phx-click="sort">Sort</button>
          <button style="padding: 5px; margin-left: 10px" phx-click="declare" > Declare</button>
        <% else %>
          <%= if @winner == @player_id do %>
           -  <span style="color: green">Winner!</span>
          <% end %>
        <% end %>
      </div>
      <hr>
      <div style="display: flex; flex-flow: row;">
        <div style="width: 150px; height: 20px; border-right: solid; text-align: center">tris 1</div>
        <div style="width: 160px; height: 20px; border-right: solid; text-align: center">tris 2</div>
        <div style="width: 220px; height: 20px; border-right: solid; text-align: center">quatris</div>
      </div>
      <div id="<%= @drop_zone_id %>" phx-hook="Drag" style="margin-top: 10px; display: flex; flex-flow: row;">
        <%= for {card, index} <- Enum.with_index(@cards) do %>
          <%= content_tag :button, SekaLive.card(card),
                draggable: "true",
                class: "draggable",
                id: "#{@player_id}-card-#{index}",
                style: "padding: 5px; margin: 5px; font-size: 20px",
                phx_click: "discard",
                phx_value_card:  card,
                disabled: @game_status == :won %>
        <% end %>
      </div>
    """
  end
end
