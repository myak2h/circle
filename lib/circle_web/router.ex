defmodule CircleWeb.Router do
  use CircleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CircleWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/seka", SekaController, :index
    post "/seka/new", SekaController, :create
    get "/seka/:id", SekaController, :show
    live "/seka/:id/live", SekaLive, :show
    post "/seka/:id", SekaController, :join
    post "/seka/:id/start", SekaController, :start
  end

  # Other scopes may use custom stacks.
  # scope "/api", CircleWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: CircleWeb.Telemetry
    end
  end
end
