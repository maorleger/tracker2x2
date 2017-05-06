defmodule Tracker2x2.AuthController do
  use Tracker2x2.Web, :controller

  def index(conn, %{"provider" => provider}) do
    redirect conn, external: authorize_url!(provider)
  end

  def callback(conn, %{"provider" => provider, "code" => code} = params) do
    client = get_token!(provider, code)
    user = get_user!(provider, client)

    conn
    |> put_session(:current_user, user)
    |> put_session(:access_token, client.token.access_token)
    |> redirect(to: "/")
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
    IO.puts "in get_token!"
    Google.get_token!(code: code)
  end

  defp get_token!("github", code) do
    GitHub.get_token!(code: code)
  end

  defp get_token!(provider, code) do
    raise "No matching provider for #{provider} with code #{code} in get_token!"
  end

  defp get_user!("google", client) do
    IO.puts "in google callback"
    IO.inspect client
    user_url = "https://www.googleapis.com/plus/v1/people/me/openIdConnect"
    %{body: user} = OAuth2.Client.get!(client, user_url)
    %{name: user["name"]}
  end

  defp get_user!("github", client) do
    IO.puts "in github callback"
    IO.inspect client
    %{body: user} = OAuth2.Client.get!(client, "https://api.github.com/user")
    %{name: user["name"], avatar: user["avatar_url"]}
  end
end
