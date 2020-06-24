defmodule Memento.Capture.Pinboard.Client do
  @moduledoc false
  alias Memento.HTTPClient

  @bom to_string([239, 187, 191])

  def get_links(token, since) do
    url = "https://api.pinboard.in/v1/posts/all"
    params = qs_params(token, since)

    case HTTPClient.get(url, [], params) do
      %{status_code: 200, body: @bom <> resp_body} ->
        Jason.decode(resp_body)

      %{status_code: 200, body: resp_body} ->
        Jason.decode(resp_body)

      error_response = %HTTPClient.ErrorResponse{} ->
        {:error, error_response}

      other_error ->
        other_error
    end
  end

  defp qs_params(token, nil) do
    %{"auth_token" => token, "format" => "json"}
  end

  defp qs_params(token, since) do
    %{
      "auth_token" => token,
      "format" => "json",
      "fromdt" => DateTime.to_iso8601(since)
    }
  end
end
