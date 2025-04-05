defmodule LtrLabs.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LtrLabs.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{
        net_total: 42,
        tax: 42,
        total: 42
      })
      |> LtrLabs.Orders.create_order()

    order
  end

  @doc """
  Generate a order_item.
  """
  def order_item_fixture(attrs \\ %{}) do
    order = order_fixture()

    {:ok, order_item} =
      attrs
      |> Enum.into(%{
        net_price: 42,
        net_total: 42,
        quantity: 42,
        total: 42,
        order_id: order.id
      })
      |> LtrLabs.Orders.create_order_item()

    order_item
  end
end
