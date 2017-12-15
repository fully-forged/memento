defmodule Memento.Capture.Instapaper.Creds do
  def get_from_env do
    %{
      consumer_key: System.get_env("INSTAPAPER_OAUTH_CONSUMER_KEY"),
      consumer_secret: System.get_env("INSTAPAPER_OAUTH_CONSUMER_SECRET"),
      username: System.get_env("INSTAPAPER_USERNAME"),
      password: System.get_env("INSTAPAPER_PASSWORD")
    }
  end
end
