defmodule Memento.HTTPClient do
  @moduledoc """
  Simple http client based on httpc.
  """

  alias Memento.HTTPClient.{ErrorResponse, Response}

  @type url :: String.t()
  @type headers :: [{String.t(), String.t()}]
  @type qs_params :: %{String.t() => String.t() | number | atom}
  @type content_type :: String.t()

  @doc """
  Issues an HTTP request to the specified url, optionally passing a list
  of headers.

  iex> Memento.HTTPClient.get("http://example.com")
  iex> Memento.HTTPClient.get("http://example.com", [{"User-Agent", "My App 2.1"}])
  """
  @spec get(url, headers) :: {:ok, Response.t()} | {:error, ErrorResponse.t()}
  def get(url, headers \\ []) do
    headers =
      Enum.map(headers, fn {k, v} ->
        {String.to_charlist(k), String.to_charlist(v)}
      end)

    :httpc.request(:get, {String.to_charlist(url), headers}, [], [])
    |> process_response
  end

  @doc """
  Issues an HTTP request to the specified endpoint, explicitly passing
  a list of headers and a map of query string params (which will be
  encoded automatically).

  iex> Memento.HTTPClient.get("http://example.com",
                            [{"User-Agent", "My App 2.1"}],
                            %{"page" => 1})
  """
  @spec get(url, headers, qs_params) ::
          {:ok, Response.t()} | {:error, ErrorResponse.t()}
  def get(url, headers, qs_params) do
    headers =
      Enum.map(headers, fn {k, v} ->
        {String.to_charlist(k), String.to_charlist(v)}
      end)

    url_with_qs = url <> "?" <> URI.encode_query(qs_params)

    :httpc.request(:get, {String.to_charlist(url_with_qs), headers}, [], [])
    |> process_response
  end

  @spec post(url, headers, binary, content_type) ::
          {:ok, Response.t()} | {:error, ErrorResponse.t()}
  def post(url, headers, body, content_type \\ "application/json") do
    headers =
      Enum.map(headers, fn {k, v} ->
        {String.to_charlist(k), String.to_charlist(v)}
      end)

    :httpc.request(
      :post,
      {String.to_charlist(url), headers, String.to_charlist(content_type),
       body},
      [],
      []
    )
    |> process_response
  end

  defp process_response({:ok, result}) do
    {{_, status, _}, headers, body} = result

    headers =
      Enum.map(headers, fn {k, v} ->
        {List.to_string(k), List.to_string(v)}
      end)

    %Response{status_code: status, headers: headers, body: body}
  end

  defp process_response({:error, reason}) do
    %ErrorResponse{message: reason}
  end
end
