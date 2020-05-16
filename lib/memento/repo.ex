defmodule Memento.Repo do
  @moduledoc false

  use Ecto.Repo, otp_app: :memento, adapter: Ecto.Adapters.Postgres
end
