defmodule LtrLabs.Orders.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(net_price quantity)a
  @optional_fields ~w(total net_total quantity order_id inserted_at)a

  schema "order_items" do
    # Total price (inc tax) of the item in cents
    field :total, :integer
    # Net price of the item in cents
    field :net_price, :integer
    # Net total of the item in cents
    field :net_total, :integer
    field :quantity, :integer
    belongs_to :order, LtrLabs.Orders.Order

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(order_item, attrs) do
    order_item
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_number(:net_price, greater_than: 0)
    |> validate_number(:quantity, greater_than: 0)
    |> validate_number(:total, greater_than: 0)
    |> validate_number(:net_total, greater_than: 0)
  end

  def update_changeset(order_item, attrs) do
    order_item
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields ++ @optional_fields)
    |> validate_number(:net_price, greater_than: 0)
    |> validate_number(:quantity, greater_than: 0)
    |> validate_number(:total, greater_than: 0)
    |> validate_number(:net_total, greater_than: 0)
  end
end
