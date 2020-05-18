defmodule MementoWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :memento

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_memento_key",
    signing_salt: "1qECk5lT"
  ]

  socket("/socket", MementoWeb.UserSocket,
    websocket: [timeout: 45_000],
    longpoll: false
  )

  socket("/live", Phoenix.LiveView.Socket,
    websocket: [timeout: 45_000, connect_info: [session: @session_options]]
  )

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :memento,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :memento
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug MementoWeb.Router

  def init(_type, config) do
    config =
      case System.get_env("PORT") do
        nil ->
          config

        port ->
          new_config = [
            http: [port: port, transport_options: [socket_opts: [:inet6]]],
            secret_key_base: System.get_env("SECRET_KEY_BASE")
          ]

          Keyword.merge(config, new_config)
      end

    {:ok, config}
  end
end
