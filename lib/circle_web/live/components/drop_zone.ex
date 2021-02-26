defmodule CircleWeb.Live.Components.DropZone do
  use Phoenix.LiveComponent
  import Phoenix.HTML.Tag
  import CircleWeb.SekaLive, only: [card_image_path: 1]

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
        <div style="width: 300px; height: 20px; border-right: solid; text-align: center">Tris</div>
        <div style="width: 295px; height: 20px; border-right: solid; text-align: center">Tris</div>
        <div style="width: 400px; height: 20px; border-right: solid; text-align: center">Quatris</div>
      </div>
      <div id="<%= @drop_zone_id %>" phx-hook="Drag" style="margin-top: 10px; display: flex; flex-flow: row;">
        <%= for {card, index} <- Enum.with_index(@cards) do %>
          <%= tag :img,
                src: "#{card_image_path(card)}",
                draggable: "true",
                class: "draggable",
                id: "#{@player_id}-card-#{index}",
                style: "margin: 5px; #{@game_status == :won && "pointer-events: none" || ""}",
                phx_click: "discard",
                phx_value_card:  card,
                alt: card,
                width: 90,
                height: 130%>
        <% end %>
      </div>
    """
  end
end
