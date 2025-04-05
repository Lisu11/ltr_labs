defmodule LtrLabs.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(tax)a
  @optional_fields ~w(net_total total)a

  schema "orders" do
    # Total amount of the order in cents
    field :total, :integer
    # Net amount of the order in cents
    field :net_total, :integer
    # Tax amount of the order in percents
    field :tax, :integer

    has_many :order_items, LtrLabs.Orders.OrderItem, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(order, attrs) do
    order
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:order_items, with: &LtrLabs.Orders.OrderItem.create_changeset/2)
    |> validate_number(:total, greater_than: 0)
    |> validate_number(:net_total, greater_than: 0)
    |> validate_number(:tax, greater_than_or_equal_to: 0)
  end

  def update_changeset(order, attrs) do
    order
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields ++ @optional_fields)
    |> cast_assoc(:order_items, with: &LtrLabs.Orders.OrderItem.update_changeset/2)
    |> validate_number(:total, greater_than: 0)
    |> validate_number(:net_total, greater_than: 0)
    |> validate_number(:tax, greater_than_or_equal_to: 0)
  end
end
