defmodule Memento.DbTestCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Memento.DbTestCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Memento.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Memento.Repo, {:shared, self()})
    end

    :ok
  end
end
