defmodule Google do
  use OAuth2.Strategy

  alias OAuth2.Strategy.AuthCode

  def client do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: System.get_env("GOOGLE_CLIENT_ID"),
      client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
      redirect_uri: System.get_env("GOOGLE_REDIRECT_URI"),
      site: "https://accounts.google.com",
      authorize_url: "https://accounts.google.com/o/oauth2/auth",
      token_url: "https://accounts.google.com/o/oauth2/token"
    ])
  end

  def authorize_url!(params \\ []) do
    OAuth2.Client.authorize_url!(client(), params)
  end

  def get_token!(params \\ [], headers \\ []) do
    IO.puts "GOOOOOOOOO"
    IO.inspect params
    OAuth2.Client.get_token!(client(), Keyword.merge(params, client_secret: client().client_secret))
  end

  # strategy callback
  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    IO.puts "in Google:get_token"
    client
    |> put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end
end
