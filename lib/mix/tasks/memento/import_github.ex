defmodule Mix.Tasks.Memento.ImportGithub do
  alias Memento.{Repo, Schema.Entry, Capture.Github}

  def run(_) do
    Application.ensure_all_started(:memento)

    now = DateTime.utc_now()

    Application.get_env(:memento, :github_username)
    |> Github.Stream.by_username()
    |> Enum.chunk_every(50)
    |> Enum.each(fn chunk ->
         inserts =
           chunk
           |> Enum.map(&Github.StarredRepo.content_from_api_result/1)
           |> Enum.map(fn sr ->
                [
                  type: :github_star,
                  content: sr,
                  saved_at: sr.starred_at,
                  inserted_at: now,
                  updated_at: now
                ]
              end)

         Repo.insert_all(Entry, inserts, on_conflict: :nothing)
       end)
  end
end
