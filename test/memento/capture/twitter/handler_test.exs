defmodule Memento.Capture.Twitter.HandlerTest do
  use ExUnit.Case, async: false
  use Memento.DbTestCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  alias Memento.Capture.Twitter.Handler

  test "authorize returns the access token" do
    use_cassette "capture_twitter_authorize" do
      data = Handler.initial_data()

      assert {:ok, %{access_token: _}} = Handler.authorize(data)
    end
  end

  test "gets favs for user" do
    use_cassette "capture_twitter_refresh" do
      data = Handler.initial_data()

      {:ok, new_data} = Handler.authorize(data)

      {:ok, result, _} = Handler.refresh(new_data)

      [twitter_content | _] = result

      assert %{id: _, created_at: _, screen_name: _, text: _, urls: _} =
               twitter_content
    end
  end
end
