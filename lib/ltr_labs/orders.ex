defmodule LtrLabs.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias LtrLabs.Repo
  alias Ecto.Multi
  alias LtrLabs.Orders.Order

  @doc """
  Returns the list of orders.

  ## Examples

      iex> list_orders()
      [%Order{}, ...]

  """
  def list_orders do
    Repo.all(Order)
  end

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(123)
      %Order{}

      iex> get_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order!(id), do: Repo.get!(Order, id)

  @doc """
  Creates a order.

  ## Examples

      iex> create_order(%{field: value})
      {:ok, %Order{}}

      iex> create_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(attrs \\ %{}) do
    %Order{}
    |> Order.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a order.

  ## Examples

      iex> update_order(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a order.

  ## Examples

      iex> delete_order(order)
      {:ok, %Order{}}

      iex> delete_order(order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  alias LtrLabs.Orders.OrderItem

  @doc """
  Returns the list of order_items.

  ## Examples

      iex> list_order_items()
      [%OrderItem{}, ...]

  """
  def list_order_items do
    Repo.all(OrderItem)
  end

  @doc """
  Gets a single order_item.

  Raises `Ecto.NoResultsError` if the Order item does not exist.

  ## Examples

      iex> get_order_item!(123)
      %OrderItem{}

      iex> get_order_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order_item!(id), do: Repo.get!(OrderItem, id)

  @doc """
  Creates a order_item.

  ## Examples

      iex> create_order_item(%{field: value})
      {:ok, %OrderItem{}}

      iex> create_order_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order_item(attrs \\ %{}) do
    %OrderItem{}
    |> OrderItem.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a order_item.

  ## Examples

      iex> update_order_item(order_item, %{field: new_value})
      {:ok, %OrderItem{}}

      iex> update_order_item(order_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order_item(%OrderItem{} = order_item, attrs) do
    order_item
    |> OrderItem.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a order_item.

  ## Examples

      iex> delete_order_item(order_item)
      {:ok, %OrderItem{}}

      iex> delete_order_item(order_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order_item(%OrderItem{} = order_item) do
    Repo.delete(order_item)
  end

  def fill_order_missing_values_no_tx(%Order{} = order) do
    order = order |> Repo.preload([:order_items], force: true)

    items_up =
      Enum.map(
        order.order_items,
        &calc_tax_attrs(&1, order.tax)
      )

    update_order(order, %{
      order_items: items_up,
      net_total: Enum.sum_by(items_up, & &1.net_total),
      total: Enum.sum_by(items_up, & &1.total)
    })
  end

  @spec fill_order_missing_values(%Order{}) ::
          {:error, Ecto.Changeset.t()} | {:ok, %Order{}}
  def fill_order_missing_values(%Order{} = order) do
    Multi.new()
    |> Multi.run(:order, fn repo, _ ->
      order
      |> repo.preload([:order_items], force: true)
      |> then(&{:ok, &1})
    end)
    |> Multi.update(:update_order, fn %{order: %{order_items: items} = order} ->
      items_attrs =
        Enum.map(items, &calc_tax_attrs(&1, order.tax))

      net_total = Enum.sum_by(items_attrs, & &1.net_total)
      total = Enum.sum_by(items_attrs, & &1.total)

      Order.update_changeset(
        order,
        %{
          order_items: items_attrs,
          net_total: net_total,
          total: total
        }
      )
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{update_order: order}} ->
        {:ok, order}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  defp calc_tax_attrs(%OrderItem{} = item, tax) do
    item_net_total = item.net_price * item.quantity
    item_total = div(item_net_total * (100 + tax), 100)

    item
    |> Map.take([:id, :net_price, :quantity, :order_id, :inserted_at])
    |> Map.merge(%{
      total: item_total,
      net_total: item_net_total
    })
  end
end
