defmodule Memento.Capture.Handler do
  alias Memento.Schema.Entry
  @type data :: Map.t()
  @type content_list :: [Entry.content()]

  @callback initial_data :: data
  @callback authorize(data) :: {:ok, data} | {:error, term()}
  @callback refresh(data) :: {:ok, content_list, data} | {:error, term()}
  @callback entry_type :: Entry.Type.t()
  @callback get_saved_at(Entry.content()) :: DateTime.t()
end
