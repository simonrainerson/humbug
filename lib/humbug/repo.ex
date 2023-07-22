defmodule Humbug.Repo do
  use Ecto.Repo,
    otp_app: :humbug,
    adapter: Ecto.Adapters.Postgres
end
