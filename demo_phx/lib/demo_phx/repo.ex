defmodule DemoPhx.Repo do
  use Ecto.Repo,
    otp_app: :demo_phx,
    adapter: Ecto.Adapters.SQLite3
end
