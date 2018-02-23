defmodule Memento.Capture.Handler do
  @moduledoc """
  The `Memento.Capture.Handler` behaviour can be used
  to implement a handler that knows how to authorize
  and fetch data from a specific source.

  A handler has an implicit lifecycle: authorization,
  refresh and processing of new data.

  This lifecycle is implemented by the `Memento.Capture.Feed` state machine.
  """
  alias Memento.Schema.Entry

  @typedoc """
  A handler's data is a map with freeform structure. This map is passed to
  the handler at different stages of its lifecycle.
  """
  @type data :: Map.t()
  @type content_list :: [Entry.content()]

  @doc """
  Returns the initial data needed by the handler to authenticate against the
  data source and fetch information. This should include any
  authorization credential or query params.
  """
  @callback initial_data :: data

  @doc """
  Given initial data, perform the authorization step and return new data
  with relevant information (e.g. an api token).

  For data sources that don't require authorization, it's enough to just return
  `{:ok, original_data}`.
  """
  @callback authorize(data) :: {:ok, data} | {:error, term()}

  @doc """
  Given data can include authorization tokens and/or query params,
  fetch the source data and process it to a list of maps that can be saved
  as content for database entries (see the docs for `Memento.Schema.Entry` for
  more details.

  Note that function has to return (if needed) updated data, with updated params
  (e.g. pagination). This is needed to provide a way to incrementally fetch changes
  from the target source.
  """
  @callback refresh(data) :: {:ok, content_list, data} | {:error, term()}

  @doc """
  A valid `Memento.Schema.Entry.Type.t` value.
  """
  @callback entry_type :: Entry.Type.t()

  @doc """
  Given a piece of content (one of the elements returned in the list from
  `refresh/1`, how to extract a `DateTime.t` that represents the point
  in time when that very piece of content was saved.
  """
  @callback get_saved_at(Entry.content()) :: DateTime.t()
end
