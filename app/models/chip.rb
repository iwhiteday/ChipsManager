class Chip < ApplicationRecord

def self.convert_from_money(currency)
  ActiveRecord::Base.transaction do
    chips = Chip.where('count > 0').to_a
    values = chips.pluck(:value)
    counts = chips.map { |chip| [chip.value, chip.count] }.to_h
    result = chips.map { |chip| [chip.value, 0] }.to_h
    result = calculate_optimal(values, currency.amount, counts, result)
    # balance_the_balance(result, currency) unless result.nil?
    result
  end
end

class << self
  private def optimal_variant(values, amount, result)
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

  private def greedy_exchange(values, amount, counts, result, index)
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

  private def calculate_optimal(values, amount, counts, result)
    # might look stupid but i'll take it
    default_result = result.clone
    result = optimal_variant(values, amount, result)
    unless result_possible?(result, counts)
      amount = calculate_remain_sum(result, counts)
      puts "Not optimal amount #{amount}"
      # result = default_result
      result = greedy_exchange(values, amount, counts, result, values.length - 1)
    end
    result
  end

  private def result_possible?(result, counts)
    subtraction = result.zip(counts).map { |result_item, counts_item| counts_item.last - result_item.last }
    subtraction.min >= 0
  end

  private def calculate_remain_sum(result, counts)
    subtraction = result.zip(counts).map { |result_item, counts_item| [counts_item.first, counts_item.last - result_item.last] }.to_h
    puts "Counts before merge: #{counts}"
    puts "Result: #{result}"
    counts.merge! subtraction.merge(subtraction) { |key, value| [value, 0].max }
    puts "Counts after merge: #{counts}"
    subtraction.reject! { |key, value| value >= 0 }
    subtraction.inject(0) do |sum, item|
      sum + (-item.last * item.first)
    end
  end

  def balance_the_balance(chips, currency)
    balance = Balance.find_by(currency: currency.currency)
    balance.amount += currency.amount
    balance.save
    Chip.all.each do |chip|
      unless chips[chip.value].nil?
        chip.count -= chips[chip.value]
        chip.save
      end
    end
  end
end

end
