defmodule CircleWeb.PageControllerTest do
  use CircleWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Circle Games"
  end
end
