defmodule LtrLabs.OrdersTest do
  use LtrLabs.DataCase

  alias LtrLabs.Orders

  describe "orders - generated" do
    alias LtrLabs.Orders.Order

    import LtrLabs.OrdersFixtures

    @invalid_attrs %{total: nil, net_total: nil, tax: nil}

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Orders.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Orders.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      valid_attrs = %{total: 42, net_total: 42, tax: 42}

      assert {:ok, %Order{} = order} = Orders.create_order(valid_attrs)
      assert order.total == 42
      assert order.net_total == 42
      assert order.tax == 42
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()
      update_attrs = %{total: 43, net_total: 43, tax: 43}

      assert {:ok, %Order{} = order} = Orders.update_order(order, update_attrs)
      assert order.total == 43
      assert order.net_total == 43
      assert order.tax == 43
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_order(order, @invalid_attrs)
      assert order == Orders.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Orders.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(order.id) end
    end
  end

  describe "order_items - generated" do
    alias LtrLabs.Orders.OrderItem

    import LtrLabs.OrdersFixtures

    @invalid_attrs %{total: nil, net_price: nil, net_total: nil, quantity: nil}

    test "list_order_items/0 returns all order_items" do
      order_item = order_item_fixture()
      assert Orders.list_order_items() == [order_item]
    end

    test "get_order_item!/1 returns the order_item with given id" do
      order_item = order_item_fixture()
      assert Orders.get_order_item!(order_item.id) == order_item
    end

    test "create_order_item/1 with valid data creates a order_item" do
      order = order_fixture()
      valid_attrs = %{total: 42, net_price: 42, net_total: 42, quantity: 42, order_id: order.id}

      assert {:ok, %OrderItem{} = order_item} = Orders.create_order_item(valid_attrs)
      assert order_item.total == 42
      assert order_item.net_price == 42
      assert order_item.net_total == 42
      assert order_item.quantity == 42
    end

    test "create_order_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order_item(@invalid_attrs)
    end

    test "update_order_item/2 with valid data updates the order_item" do
      order_item = order_item_fixture()
      update_attrs = %{total: 43, net_price: 43, net_total: 43, quantity: 43}

      assert {:ok, %OrderItem{} = order_item} = Orders.update_order_item(order_item, update_attrs)
      assert order_item.total == 43
      assert order_item.net_price == 43
      assert order_item.net_total == 43
      assert order_item.quantity == 43
    end

    test "update_order_item/2 with invalid data returns error changeset" do
      order_item = order_item_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_order_item(order_item, @invalid_attrs)
      assert order_item == Orders.get_order_item!(order_item.id)
    end

    test "delete_order_item/1 deletes the order_item" do
      order_item = order_item_fixture()
      assert {:ok, %OrderItem{}} = Orders.delete_order_item(order_item)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order_item!(order_item.id) end
    end
  end

  describe "orders" do
    alias LtrLabs.Orders.Order

    import LtrLabs.OrdersFixtures

    test "create_order/1 with nested items data creates a order" do
      valid_attrs = %{
        tax: 23,
        order_items: [%{net_price: 42, quantity: 1}, %{net_price: 24, quantity: 2}]
      }

      assert {:ok, %Order{} = order} = Orders.create_order(valid_attrs)

      assert order.tax == 23
      assert is_nil(order.total)
      assert is_nil(order.net_total)
      assert length(order.order_items) == 2
      assert Enum.at(order.order_items, 0).net_price == 42
      assert Enum.at(order.order_items, 0).quantity == 1
      assert Enum.at(order.order_items, 1).net_price == 24
      assert Enum.at(order.order_items, 1).quantity == 2
      assert is_nil(Enum.at(order.order_items, 0).total)
      assert is_nil(Enum.at(order.order_items, 1).total)
      assert is_nil(Enum.at(order.order_items, 0).net_total)
      assert is_nil(Enum.at(order.order_items, 1).net_total)
      assert Enum.all?(order.order_items, &(&1.order_id == order.id))
    end

    test "create_order/1 with nested items data and invalid data returns error changeset" do
      valid_attrs1 = %{
        tax: 23,
        order_items: [%{net_price: 42, quantity: 1}, %{net_price: -24, quantity: 2}]
      }

      valid_attrs2 = %{tax: 23, order_items: [%{net_price: 42, quantity: 1}, %{net_price: 24}]}
      valid_attrs3 = %{tax: 23, order_items: [%{net_price: 42, quantity: 1}, %{quantity: 2}]}

      assert {:error, %Ecto.Changeset{}} = Orders.create_order(valid_attrs1)
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(valid_attrs2)
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(valid_attrs3)
    end
  end

  describe "Orders.fill_order_missing_values/1" do
    alias LtrLabs.Orders.Order

    import LtrLabs.OrdersFixtures

    setup do
      valid_attrs = %{
        tax: 50,
        order_items: [%{net_price: 42, quantity: 1}, %{net_price: 24, quantity: 2}]
      }

      {:ok, order} = Orders.create_order(valid_attrs)
      tax = :rand.uniform(100) |> trunc()
      items_count = :rand.uniform(30) |> trunc()

      items =
        Enum.map(1..items_count, fn _ ->
          %{
            net_price: :rand.uniform(1000) |> trunc(),
            quantity: :rand.uniform(100) |> trunc()
          }
        end)

      %{order: order, order_attrs: valid_attrs, random_attrs: %{tax: tax, order_items: items}}
    end

    test "fill_order_missing_values/1 does not add nor remove any orders", %{order: order} do
      assert {:ok, order_up} = Orders.fill_order_missing_values(order)

      assert Enum.count(order_up.order_items) == 2

      assert Enum.all?(
               order_up.order_items,
               fn item ->
                 Enum.any?(
                   order.order_items,
                   &(&1.quantity == item.quantity and
                       &1.net_price == item.net_price)
                 )
               end
             )
    end

    test "inserted_at timestamp is correct", %{order_attrs: attrs} do
      {:ok, order} = Orders.create_order(attrs)
      :timer.sleep(2000)
      {:ok, order_up} = Orders.fill_order_missing_values(order)
      assert DateTime.compare(order_up.inserted_at, order.inserted_at) == :eq

      assert Enum.all?(
               order.order_items,
               &(DateTime.compare(&1.inserted_at, &1.inserted_at) == :eq)
             )

      assert DateTime.compare(
               Enum.find(order_up.order_items, &(&1.quantity == 1)).inserted_at,
               Enum.find(order.order_items, &(&1.quantity == 1)).inserted_at
             ) == :eq

      assert DateTime.compare(
               Enum.find(order_up.order_items, &(&1.quantity == 2)).inserted_at,
               Enum.find(order.order_items, &(&1.quantity == 2)).inserted_at
             ) == :eq

      assert DateTime.compare(
               Enum.find(order_up.order_items, &(&1.quantity == 2)).inserted_at,
               Enum.find(order_up.order_items, &(&1.quantity == 2)).updated_at
             ) == :lt

      assert DateTime.compare(
               Enum.find(order_up.order_items, &(&1.quantity == 1)).inserted_at,
               Enum.find(order_up.order_items, &(&1.quantity == 1)).updated_at
             ) == :lt
    end

    test "tax values are correct for random order", %{random_attrs: attrs} do
      tax = attrs.tax

      {:ok, order} =
        attrs
        |> Orders.create_order()
        |> elem(1)
        |> Orders.fill_order_missing_values()

      assert order.tax == tax
      assert order.net_total == Enum.sum_by(order.order_items, & &1.net_total)
      assert order.total == Enum.sum_by(order.order_items, & &1.total)

      assert Enum.all?(order.order_items, fn item ->
               item.net_price * item.quantity == item.net_total
             end)

      assert Enum.all?(order.order_items, fn item ->
               item.total == div(item.net_total * (100 + tax), 100)
             end)
    end

    test "tax values are correct for order from setup", %{order: order} do
      {:ok, order} = Orders.fill_order_missing_values(order)

      assert order.net_total == 90
      assert order.total == 135

      assert Enum.any?(order.order_items, fn item ->
               item.net_price == item.net_total and
                 item.net_price == 42 and
                 item.total == 63 and
                 item.id == 1
             end)

      assert Enum.any?(order.order_items, fn item ->
               item.net_price == 24 and
                 item.net_total == 48 and
                 item.total == 72 and
                 item.quantity == 2 and
                 item.id == 2
             end)
    end

    test "order items updated after fetch should not cause any problems", %{order: order} do
      order_before_update =
        Orders.get_order!(order.id) |> LtrLabs.Repo.preload([:order_items], force: true)

      assert Enum.count(order_before_update.order_items) == 2
      assert is_nil(order_before_update.total)

      {:ok, _new_item_added_by_separate_process} =
        Orders.create_order_item(%{order_id: order.id, quantity: 1, net_price: 1})

      order_after_insert =
        Orders.get_order!(order.id) |> LtrLabs.Repo.preload([:order_items], force: true)

      assert Enum.count(order_after_insert.order_items) == 3
      assert is_nil(order_after_insert.total)

      {:ok, order_after_update} = Orders.fill_order_missing_values(order_before_update)

      # fill_order_missing_values takes into consideration
      # third order_item that is not present in `order_before_update`
      assert Enum.count(order_after_update.order_items) == 3
      assert order_after_update.total == 136
      assert order_after_update.net_total == 91
    end
  end
end
