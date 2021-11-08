defmodule DemoPhx.Repo do
  use Ecto.Repo,
    otp_app: :demo_phx,
    adapter: Ecto.Adapters.Postgres
end
