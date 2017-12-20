defmodule Memento.Capture.Twitter.HandlerTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  alias Memento.Capture.Twitter.Handler

  test "authorize returns the access token" do
    use_cassette "capture_twitter" do
      data = Handler.initial_data()

      assert {:ok, %{access_token: _}} = Handler.authorize(data)
    end
  end
end
