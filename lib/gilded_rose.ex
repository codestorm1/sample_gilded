defmodule GildedRose do
  use Agent
  alias GildedRose.Item

  def new() do
    {:ok, agent} =
      Agent.start_link(fn ->
        [
          Item.new("+5 Dexterity Vest", 10, 20),
          Item.new("Aged Brie", 2, 0),
          Item.new("Elixir of the Mongoose", 5, 7),
          Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
          Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
          Item.new("Conjured Mana Cake", 3, 6)
        ]
      end)

    agent
  end

  def items(agent), do: Agent.get(agent, & &1)

  def adjust_backstage_quality(item) do
    quality =
      case item.sell_in do
        x when x <= 0 ->
          0

        x when x <= 5 ->
          item.quality + 3

        x when x <= 10 ->
          item.quality + 2

        x when x >= 50 ->
          50

        _ ->
          item.quality + 1
      end

    %{item | quality: quality}
  end

  def adjust_brie_quality(item) do
    # TODO: Brie shouldn't increase quality by 2 after sell_in date
    # Keep it this way for backward compatibility
    quality_rate = if item.sell_in > 0, do: 1, else: 2
    %{item | quality: min(item.quality + quality_rate, 50)}
  end

  def adjust_conjured_quality(item) do
    %{item | quality: max(item.quality - 2, 0)}
  end

  def adjust_standard_item_quality(item) do
    quality_rate = if item.sell_in > 0, do: 1, else: 2
    %{item | quality: max(item.quality - quality_rate, 0)}
  end

  def adjust_quality(item) do
    case item.name do
      "Aged Brie" ->
        adjust_brie_quality(item)

      "Backstage passes to a TAFKAL80ETC concert" ->
        adjust_backstage_quality(item)

      "Conjured Mana Cake" ->
        adjust_conjured_quality(item)

      "Sulfuras, Hand of Ragnaros" ->
        item

      _ ->
        adjust_standard_item_quality(item)
    end
  end

  def adjust_item_sell_in(item) do
    if item.name == "Sulfuras, Hand of Ragnaros",
      do: item,
      else: %{item | sell_in: item.sell_in - 1}
  end

  @spec process_item(atom | %{:name => any, optional(any) => any}) ::
          atom | %{:name => any, optional(any) => any}
  def process_item(item) do
    item = adjust_quality(item)
    adjust_item_sell_in(item)
  end

  def update_quality(agent) do
    for i <- 0..(Agent.get(agent, &length/1) - 1) do
      item = Agent.get(agent, &Enum.at(&1, i))
      item = process_item(item)
      Agent.update(agent, &List.replace_at(&1, i, item))
    end

    :ok
  end
end
