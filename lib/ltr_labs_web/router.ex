defmodule LtrLabsWeb.Router do
  use LtrLabsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", LtrLabsWeb do
    pipe_through :api
  end
end
