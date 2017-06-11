defmodule Tracker2x2.Router do
  use Tracker2x2.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Tracker2x2.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Tracker2x2.ApiAuth
  end

  scope "/", Tracker2x2 do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/app", Tracker2x2 do
    pipe_through :browser

    get "/", AppController, :index
  end

  scope "/token", Tracker2x2 do
    pipe_through :browser

    get "/edit", TokenController, :edit
    get "/create", TokenController, :create
    put "/update", TokenController, :update
  end

  scope "/auth", Tracker2x2 do
    pipe_through :browser

    get "/destroy", AuthController, :destroy
    get "/:provider", AuthController, :index
    get "/:provider/callback", AuthController, :callback
  end

  scope "/api", Tracker2x2 do
    pipe_through :api

    get "/", ApiController, :test
    get "/:project_id/epics", ApiController, :epics
    get "/:project_id/stories", ApiController, :stories
  end

  # Other scopes may use custom stacks.
  # scope "/api", Tracker2x2 do
  #   pipe_through :api
  # end
end
