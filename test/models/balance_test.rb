require 'test_helper'

class BalanceTest < ActiveSupport::TestCase

  test "should convert chips to balance" do
    chips = ActionController::Parameters.new(   '100' => '0',
                                                  '50' => '3',
                                                  '25' => '0',
                                                  '10' => '2',
                                                  '5' => '14',
                                                  '1' => '0')
    result = Balance.exchange_chips(chips, 'usd')
    assert_equal(240, result)
  end

  test "should convert 0 chips to 0" do
    chips = ActionController::Parameters.new(   '100' => '0',
                                                '50' => '0',
                                                '25' => '0',
                                                '10' => '0',
                                                '5' => '0',
                                                '1' => '0')
    result = Balance.exchange_chips(chips, 'usd')
    assert_equal(0, result)
  end

  test "should raise ArgumentError with count < 0" do
    chips = ActionController::Parameters.new(   '100' => '0',
                                                '50' => '-5',
                                                '25' => '2',
                                                '10' => '-3',
                                                '5' => '0',
                                                '1' => '0')
    assert_raises ArgumentError do
      Balance.exchange_chips(chips, 'usd')
    end
  end

  test "should not convert more than having on balance to chips" do
    chips = ActionController::Parameters.new(   '100' => '80',
                                                '50' => '80',
                                                '25' => '5',
                                                '10' => '5',
                                                '5' => '5',
                                                '1' => '3')
    result = Balance.exchange_chips(chips, 'usd')
    assert_nil(result)
  end
end
