defmodule Shares.Repo do
  use Ecto.Repo,
    otp_app: :shares,
    adapter: Ecto.Adapters.Postgres
end
