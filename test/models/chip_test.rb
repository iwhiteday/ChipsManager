require 'test_helper'

class ChipTest < ActiveSupport::TestCase
  test "should not create a chip without a value" do
    chip = Chip.new
    assert_not chip.save, "Saved chip without value"
  end

  test "should convert 100 to chips" do
    currency = Balance.new(currency: 'usd', amount: 100)
    result = Chip.convert_from_money currency
    assert_equal({ 100 => 0, 50 => 1, 25 => 1, 10 => 1, 5 => 2, 1 => 5 }, result)
  end

  test "should convert 0 to 0 chips" do
    currency = Balance.new(currency: 'usd', amount: 0)
    result = Chip.convert_from_money currency
    assert_equal({ 100 => 0, 50 => 0, 25 => 0, 10 => 0, 5 => 0, 1 => 0 }, result)
  end

  test "should raise ArgumentError with amount < 0" do
    currency = Balance.new(currency: 'usd', amount: -1)
    assert_raises ArgumentError do
      Chip.convert_from_money currency
    end
  end

  test "should convert more than having on balance to nil" do
    currency = Balance.new(currency: 'usd', amount: 10000000)
    result = Chip.convert_from_money currency
    assert_nil(result)
  end
end
