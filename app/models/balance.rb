class Balance < ApplicationRecord

  def self.exchange_chips(chips, balance)
    ActiveRecord::Base.transaction do
      sum = chips.to_unsafe_h.inject(0) { |sum, item| sum + item.first.to_i * item.last.to_i }
      chips.transform_values! { |x| -(x.to_i) }
      chips.transform_keys!(&:to_i)
      Chip.balance_the_balance(chips.to_unsafe_h, Balance.new(currency: balance, amount: -sum))
    end
  end
end
