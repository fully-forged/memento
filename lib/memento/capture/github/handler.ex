defmodule Memento.Capture.Github.Handler do
  @moduledoc false
  @behaviour Memento.Capture.Handler

  alias Memento.Capture.Github.{Client, StarredRepo}

  def entry_type, do: :github_star

  def get_saved_at(content), do: content.starred_at

  def initial_data do
    %{username: Application.get_env(:memento, :github_username)}
  end

  def authorize(data) do
    {:ok, data}
  end

  def refresh(data) do
    case Client.get_stars_by_username(data.username) do
      {:ok, resp} ->
        {:ok, Enum.map(resp, &StarredRepo.content_from_api_result/1), data}

      error ->
        error
    end
  end
end
