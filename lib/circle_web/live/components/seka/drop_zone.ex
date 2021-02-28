defmodule CircleWeb.Live.Components.Seka.DropZone do
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
        <div style="position: relative;  display: flex; flex-flow: row;">
          <div style="position: relative; width: 150px; min-width: 150px; height: 20px; border-right: solid 1px; text-align: center">Tris</div>
          <div style="position: relative; width: 150px; min-width: 150px; height: 20px; border-right: solid 1px; text-align: center">Tris</div>
          <div style="position: relative; width: 200px; min-width: 200px; height: 20px; border-right: solid 1px; text-align: center">Quatris</div>
        </div>
        <div id="<%= @drop_zone_id %>" phx-hook="Drag" style="margin-top: 10px; margin-left: 0px; display: flex;">
          <%= for {card, index} <- Enum.with_index(@cards) do %>
            <%= tag :img,
                  src: "#{card_image_path(card)}",
                  draggable: "true",
                  class: "draggable",
                  id: "#{@player_id}-card-#{index}",
                  style: "position: relative; left: #{- index * 50}px;",
                  phx_click: "discard",
                  phx_value_card:  card,
                  alt: card,
                  width: 100,
                  height: 150%>
          <% end %>
        </div>
      </div>
      <br>
      <div style="padding-left: 10px;">
        <button style="padding: 5px; font-size: 20px" phx-click="sort">Sort</button>
        <button style="padding: 5px; margin-left: 20px; font-size: 20px" phx-click="declare">Declare</button>
      </div>
    """
  end
end
