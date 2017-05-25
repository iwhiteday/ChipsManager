class Balance < ApplicationRecord

  def self.exchange_chips(chips, balance)
    ActiveRecord::Base.transaction do
      # transform values to reject values < 0 and prepare for balancing
      chips.transform_values! { |x| -[x.to_i, 0].max }
      sum = chips.to_unsafe_h.inject(0) { |sum, item| sum + (item.first.to_i * item.last.to_i).abs }
      chips.transform_keys!(&:to_i)
      Chip.balance_the_balance(chips.to_unsafe_h, Balance.new(currency: balance, amount: -sum))
      sum
    end
  end
end
