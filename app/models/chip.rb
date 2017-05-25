class Chip < ApplicationRecord
  validates :value, presence: true, uniqueness: true

  after_initialize :set_defaults

  private

  def set_defaults
    self.count ||= 0
  end

  class << self
    def convert_from_money(currency)
      ActiveRecord::Base.transaction do
        raise ArgumentError, 'Amount < 0' if currency.amount < 0
        chips = Chip.where('count > 0').to_a
        values = chips.pluck(:value)
        counts = chips.map { |chip| [chip.value, chip.count] }.to_h
        result = chips.map { |chip| [chip.value, 0] }.to_h
        result = calculate_optimal(values, currency.amount, counts, result)
        balance_the_balance(result, currency) unless result.nil?
        result
      end
    end

    def add(chips)
      Chip.all.each do |chip|
        unless chips[chip.value].nil?
          chip.count -= chips[chip.value]
          chip.save
        end
      end
    end

    def balance_the_balance(chips, currency)
      balance = Balance.find_by(currency: currency.currency)
      balance.amount += currency.amount
      balance.save
      add(chips)
    end

    private

    def greedy_exchange(values, amount, counts, result, index)
      if amount.zero?
        result
      elsif index == -1
        nil
      else
        while amount >= values[index] && counts[values[index]] > 0
          amount -= values[index]
          result[values[index]] += 1
          counts[values[index]] -= 1
        end
        greedy_exchange(values, amount, counts, result, index - 1)
      end
    end


    def optimal_variant(values, amount, result)
      while amount > 0
        values.each do |value|
          if amount >= value
            amount -= value
            result[value] += 1
          end
        end
      end
      result
    end

    def calculate_optimal(values, amount, counts, result)
      # might look stupid but i'll take it
      default_result = result.clone
      result = optimal_variant(values, amount, result)
      unless result_possible?(result, counts)
        result = default_result
        result = greedy_exchange(values, amount, counts, result, values.length - 1)
      end
      result
    end

    def result_possible?(result, counts)
      subtraction = result.zip(counts).map { |result_item, counts_item| counts_item.last - result_item.last }
      subtraction.min >= 0
    end
  end

end
