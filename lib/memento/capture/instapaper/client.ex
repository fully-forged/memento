defmodule Memento.Capture.Instapaper.Client do
  @moduledoc false
  alias Memento.HTTPClient

  @base_url "https://www.instapaper.com/api/1"
  @default_limit 200

  def get_access_token(consumer_key, consumer_secret, username, password) do
    case do_get_access_token(consumer_key, consumer_secret, username, password) do
      %{status_code: 200, body: body} ->
        {:ok, URI.decode_query(body)}

      %{body: body} ->
        {:error, body}

      error ->
        error
    end
  end

  def get_bookmarks(consumer_key, consumer_secret, token, token_secret) do
    case do_get_bookmarks(consumer_key, consumer_secret, token, token_secret) do
      %{status_code: 200, body: body} ->
        Jason.decode(body)

      %{body: body} ->
        {:error, body}

      error ->
        error
    end
  end

  defp do_get_access_token(consumer_key, consumer_secret, username, password) do
    creds =
      OAuther.credentials(
        consumer_key: consumer_key,
        consumer_secret: consumer_secret
      )

    url = @base_url <> "/oauth/access_token"

    params =
      OAuther.sign(
        "post",
        url,
        [
          {"x_auth_username", username},
          {"x_auth_password", password},
          {"x_auth_mode", "client_auth"}
        ],
        creds
      )

    {header, req_params} = OAuther.header(params)

    body_params = URI.encode_query(req_params)

    HTTPClient.post(
      url,
      [header],
      body_params,
      "application/x-www-form-urlencoded"
    )
  end

  def do_get_bookmarks(consumer_key, consumer_secret, token, token_secret) do
    creds =
      OAuther.credentials(
        consumer_key: consumer_key,
        consumer_secret: consumer_secret,
        token: token,
        token_secret: token_secret
      )

    url = @base_url <> "/bookmarks/list"

    params = OAuther.sign("post", url, [{"limit", @default_limit}], creds)

    {header, req_params} = OAuther.header(params)

    body_params = URI.encode_query(req_params)

    HTTPClient.post(
      url,
      [header],
      body_params,
      "application/x-www-form-urlencoded"
    )
  end
end
