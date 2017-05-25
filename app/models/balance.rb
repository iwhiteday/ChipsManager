class Balance < ApplicationRecord

  def self.exchange_chips(chips, currency)
    ActiveRecord::Base.transaction do
      chips.transform_values! { |value| -value.to_i }
      chips.transform_keys!(&:to_i)
      # > 0 because of -value in transform
      raise ArgumentError, 'Chips count < 0' if chips.values.max > 0
      sum = chips.to_unsafe_h.inject(0) { |sum, item| sum + (item.first * item.last).abs }
      # shoulda optimize this
      actual_balance = Balance.find_by(currency: currency).amount
      if sum < actual_balance
        Chip.balance_the_balance(chips.to_unsafe_h, Balance.new(currency: currency, amount: -sum))
        sum
      else
        nil
      end
    end
  end

  def self.add(balance)
    balance_to_modify = Balance.find_by(currency: balance.currency)
    balance_to_modify.amount += balance.amount
    balance_to_modify.save
  end
end
