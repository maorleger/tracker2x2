defmodule Tracker2x2.Router do
  use Tracker2x2.Web, :router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true
  end

  scope "/" do
    pipe_through :browser
    coherence_routes
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  scope "/", Tracker2x2 do
    pipe_through :browser
  end

  scope "/", Tracker2x2 do
    pipe_through :protected
    get "/", PageController, :index
  end

  scope "/api", Tracker2x2 do
    pipe_through :api
    
    post "/token", PageController, :update_token
  end
end
