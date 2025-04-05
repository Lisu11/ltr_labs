defmodule LtrLabs.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :net_total, :integer, null: true
      add :tax, :integer, null: false
      add :total, :integer, null: true

      timestamps(type: :utc_datetime)
    end
  end
end
