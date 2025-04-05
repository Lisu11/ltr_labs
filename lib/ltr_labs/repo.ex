defmodule LtrLabs.Repo do
  use Ecto.Repo,
    otp_app: :ltr_labs,
    adapter: Ecto.Adapters.SQLite3
end
