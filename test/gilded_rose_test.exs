defmodule GildedRoseTest do
  use ExUnit.Case
  doctest GildedRose

  test "interface specification" do
    gilded_rose = GildedRose.new()
    [%GildedRose.Item{} | _] = GildedRose.items(gilded_rose)
    assert :ok == GildedRose.update_quality(gilded_rose)
  end

  test "+5 Dexterity Vest" do
    item_name = "+5 Dexterity Vest"
    gilded_rose = GildedRose.new()
    verify_status(gilded_rose, item_name, 10, 20)

    update_quality_times(gilded_rose, 10)
    verify_status(gilded_rose, item_name, 0, 10)

    update_quality_times(gilded_rose, 1)
    verify_status(gilded_rose, item_name, -1, 8)

    update_quality_times(gilded_rose, 1)
    verify_status(gilded_rose, item_name, -2, 6)

    update_quality_times(gilded_rose, 6)
    verify_status(gilded_rose, item_name, -8, 0)
  end

  # Quality increases by double after sell_in date.
  # Was this intended?  Only Leeroy knows...
  # Keep the results the same to avoid breaking external clients.
  test "Aged Brie" do
    gilded_rose = GildedRose.new()
    verify_status(gilded_rose, "Aged Brie", 2, 0)

    update_quality_times(gilded_rose, 10)
    verify_status(gilded_rose, "Aged Brie", -8, 18)

    update_quality_times(gilded_rose, 10)
    verify_status(gilded_rose, "Aged Brie", -18, 38)

    update_quality_times(gilded_rose, 20)
    verify_status(gilded_rose, "Aged Brie", -38, 50)
  end

  test "Elixir of the Mongoose" do
    item_name = "Elixir of the Mongoose"
    gilded_rose = GildedRose.new()
    verify_status(gilded_rose, item_name, 5, 7)

    update_quality_times(gilded_rose, 5)
    verify_status(gilded_rose, item_name, 0, 2)

    update_quality_times(gilded_rose, 1)
    verify_status(gilded_rose, item_name, -1, 0)

    update_quality_times(gilded_rose, 5)
    verify_status(gilded_rose, item_name, -6, 0)
  end

  test "Sulfuras, Hand of Ragnaros" do
    item_name = "Sulfuras, Hand of Ragnaros"
    gilded_rose = GildedRose.new()
    verify_status(gilded_rose, item_name, 0, 80)

    update_quality_times(gilded_rose, 5)
    verify_status(gilded_rose, item_name, 0, 80)

    update_quality_times(gilded_rose, 100)
    verify_status(gilded_rose, item_name, 0, 80)
  end

  test "Backstage passes to a TAFKAL80ETC concert" do
    item_name = "Backstage passes to a TAFKAL80ETC concert"
    gilded_rose = GildedRose.new()
    verify_status(gilded_rose, item_name, 15, 20)

    update_quality_times(gilded_rose, 5)
    verify_status(gilded_rose, item_name, 10, 25)

    update_quality_times(gilded_rose, 5)
    verify_status(gilded_rose, item_name, 5, 35)

    update_quality_times(gilded_rose, 5)
    verify_status(gilded_rose, item_name, 0, 50)

    update_quality_times(gilded_rose, 1)
    verify_status(gilded_rose, item_name, -1, 0)
  end

  test "Conjured Mana Cake" do
    item_name = "Conjured Mana Cake"
    gilded_rose = GildedRose.new()
    verify_status(gilded_rose, item_name, 3, 6)

    update_quality_times(gilded_rose, 2)
    verify_status(gilded_rose, item_name, 1, 2)

    update_quality_times(gilded_rose, 1)
    verify_status(gilded_rose, item_name, 0, 0)

    update_quality_times(gilded_rose, 1)
    verify_status(gilded_rose, item_name, -1, 0)
  end

  defp update_quality_times(gilded_rose, times) do
    for _ <- 1..times, do: GildedRose.update_quality(gilded_rose)
  end

  defp find_by_name(list, name) do
    Enum.find(list, fn i -> i.name == name end)
  end

  defp assert_equal(field, expected, actual) do
    assert(
      actual == expected,
      "actual #{field} #{actual} did not match expected #{expected}"
    )
  end

  defp verify_status(gilded_rose, item_name, sell_in, quality) do
    item = find_by_name(GildedRose.items(gilded_rose), item_name)
    assert_equal("sell_in", sell_in, item.sell_in)
    assert_equal("quality", quality, item.quality)
  end
end
