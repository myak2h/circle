defmodule CircleWeb.SekaController do
  use CircleWeb, :controller
  alias Circle.Game
  alias Circle.Games.Seka
  plug :put_layout, "seka.html"

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"seka" => %{"name" => creator_name}}) do
    {creator_id, seka_game} = Seka.new(creator_name)
    game = Game.new(seka_game)

    conn
    |> put_session("#{game.id}_player_id", creator_id)
    |> redirect(to: Routes.seka_path(conn, :show, game.id))
  end

  def show(conn, %{"id" => id}) do
    game = Game.get(id)

    case get_session(conn, "#{id}_player_id") do
      nil ->
        render(conn, "join.html", game: game)

      player_id ->
        live_render(conn, CircleWeb.Surface.Seka.Game,
          session: %{
            "game" => game,
            "player_id" => player_id
          }
        )
    end
  end

  def join(conn, %{"id" => id, "seka" => %{"name" => name}}) do
    game = Game.get(id)
    {player_id, game_data} = game.data |> Seka.parse() |> Seka.add_player(name)

    game = Game.update(game, game_data)

    conn
    |> put_session("#{game.id}_player_id", player_id)
    |> redirect(to: Routes.seka_path(conn, :show, game.id))
  end

  def start(conn, %{"id" => id}) do
    game = Game.get(id)
    game_data = game.data |> Seka.parse() |> Seka.start()
    game = Game.update(game, game_data)

    redirect(conn, to: Routes.seka_path(conn, :show, game.id))
  end
end
