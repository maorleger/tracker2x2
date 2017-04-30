defmodule Tracker2x2.RoomChannel do
  use Tracker2x2.Web, :channel
  require Logger
  def join("room:lobby", payload, socket) do
    Logger.info("In join")
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    Logger.info("ping")
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("new_msg", %{"user_id" => user_id, "token" => token}, socket) do
    Logger.info("room:lobby")
    user = Repo.get!(Tracker2x2.User, user_id)
    changeset = Tracker2x2.User.changeset(Repo.get!(Tracker2x2.User, user_id), %{token: token})
    Repo.update(changeset)
    {:reply, {:ok, %{"user_id" => user_id}}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    Logger.info("shout")
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
