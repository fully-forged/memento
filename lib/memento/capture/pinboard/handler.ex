defmodule Memento.Capture.Pinboard.Handler do
  @behaviour Memento.Capture.Handler

  alias Memento.Capture.Pinboard.{Client, Link}
  alias Memento.{Entry.Query, Repo}

  def entry_type, do: :pinboard_link

  def get_saved_at(content), do: content.time

  def initial_data do
    %{
      api_token: System.get_env("PINBOARD_API_TOKEN")
    }
  end

  def authorize(data), do: {:ok, data}

  def refresh(data) do
    max_saved_at = get_max_saved_at()

    case Client.get_links(data.api_token, max_saved_at) do
      {:ok, resp} ->
        {:ok, Enum.map(resp, &Link.content_from_api_result/1), data}

      error ->
        error
    end
  end

  defp get_max_saved_at do
    Query.max_pinboard_saved_at()
    |> Repo.one()
  end
end
