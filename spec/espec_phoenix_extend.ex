defmodule ESpec.Phoenix.Extend do
  def model do
    quote do
      alias Tracker2x2.Repo
    end
  end

  def controller do
    quote do
      alias Tracker2x2
      import Tracker2x2.Router.Helpers

      @endpoint Tracker2x2.Endpoint
    end
  end

  def view do
    quote do
      import Tracker2x2.Router.Helpers
    end
  end

  def channel do
    quote do
      alias Tracker2x2.Repo

      @endpoint Tracker2x2.Endpoint
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
