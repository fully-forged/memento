defmodule Memento.API.EntriesResource do
  use PlugRest.Resource

  def to_html(conn, state) do
    {"Hello world!", conn, state}
  end
end
