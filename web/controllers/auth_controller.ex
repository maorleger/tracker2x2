defmodule Tracker2x2.AuthController do
  use Tracker2x2.Web, :controller

  def index(conn, %{"provider" => provider}) do
    redirect conn, external: authorize_url!(provider)
  end

  def destroy(conn, _params) do
    conn
    |> delete_session(:oauth_email)
    |> delete_session(:access_token)
    |> redirect(to: page_path(conn, :index))
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    client = get_token!(provider, code)
    %{email: email} = get_user!(provider, client)

    conn
    |> put_session(:oauth_email, email)
    |> put_session(:access_token, client.token.access_token)
    |> configure_session(renew: true)
    |> redirect(to: page_path(conn, :index))
  end

  defp authorize_url!("google") do
    Google.authorize_url!(scope: "https://www.googleapis.com/auth/userinfo.email")
  end

  defp authorize_url!("github") do
    GitHub.authorize_url!(scope: "user:email")
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
    %{email: user["email"]}
  end

  defp get_user!("github", client) do
    %{body: user_emails} = OAuth2.Client.get!(client, "https://api.github.com/user/emails")
    email = case Enum.find(user_emails, fn(email) -> email["primary"] end) do
      nil -> nil
      record -> record["email"]
    end
    %{email: email}
  end
end
