defmodule LtrLabs.Repo.Migrations.CreateOrderItems do
  use Ecto.Migration

  def change do
    create table(:order_items) do
      add :net_price, :integer, null: false
      add :net_total, :integer, null: true
      add :total, :integer, null: true
      add :quantity, :integer, null: false
      add :order_id, references(:orders, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:order_items, [:order_id])
  end
end
