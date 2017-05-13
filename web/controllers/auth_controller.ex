defmodule Tracker2x2.AuthController do
  use Tracker2x2.Web, :controller

  def index(conn, %{"provider" => provider}) do
    redirect conn, external: authorize_url!(provider)
  end

  def destroy(conn, _params) do
    conn
    |> delete_session(:current_user)
    |> delete_session(:access_token)
    |> redirect(to: page_path(conn, :index))
  end

  def callback(conn, %{"provider" => provider, "code" => code} = params) do
    client = get_token!(provider, code)
    user = get_user!(provider, client)

    conn
    |> put_session(:current_user, user)
    |> put_session(:access_token, client.token.access_token)
    |> redirect(to: elm_path(conn, :index))
  end

  defp authorize_url!("google") do
    Google.authorize_url!(scope: "https://www.googleapis.com/auth/userinfo.email")
  end

  defp authorize_url!("github") do
    GitHub.authorize_url!
  end

  defp authorize_url!(url) do
    raise "No matching provider for #{url} in authorize_url!"
  end

  defp get_token!("google", code) do
    Google.get_token!(code: code)
  end

  defp get_token!("github", code) do
    GitHub.get_token!(code: code)
  end

  defp get_token!(provider, code) do
    raise "No matching provider for #{provider} with code #{code} in get_token!"
  end

  defp get_user!("google", client) do
    user_url = "https://www.googleapis.com/plus/v1/people/me/openIdConnect"
    %{body: user} = OAuth2.Client.get!(client, user_url)
    %{name: user["name"], email: user["email"]}
  end

  defp get_user!("github", client) do
    %{body: user} = OAuth2.Client.get!(client, "https://api.github.com/user")
    %{name: user["name"], email: user["email"]}
  end
end
