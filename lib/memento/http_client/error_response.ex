defmodule Memento.HTTPClient.ErrorResponse do
  @moduledoc false
  defstruct message: nil

  @type t :: %__MODULE__{message: nil | String.t()}
end
