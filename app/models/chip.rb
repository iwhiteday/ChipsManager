class Chip < ApplicationRecord

def self.convert_from_money(currency)
  ActiveRecord::Base.transaction do
    chips = Chip.where('count > 0').to_a
    values = chips.pluck(:value)
    counts = chips.map { |c| [c.value, c.count] }.to_h
    result = chips.map { |c| [c.value, 0] }.to_h
    result = try_optimal(values, currency.amount, counts, result)
    balance_the_balance(result, currency) unless result.nil?
    result
  end
end

class << self
  private def optimal(values, amount, result)
    while amount > 0
      values.each do |x|
        if amount >= x
          amount -= x
          result[x] += 1
        end
      end
    end
    result
  end

  private def greedy(values, amount, counts, result, index)
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
      greedy(values, amount, counts, result, index - 1)
    end
  end

  private def try_optimal(values, amount, counts, result)
    # might look stupid but i'll take it
    default_result = result.clone
    result = optimal(values, amount, result)
    unless result_possible?(result, counts)
      #TODO: посчитать остаток который не получается добрать оптималкой и добрать его жадюгой
      result = default_result
      result = greedy(values, amount, counts, result, values.length - 1)
    end
    result
  end

  private def result_possible?(result, counts)
    subtraction = result.zip(counts).map { |x,y| y.last - x.last }
    subtraction.min >= 0
  end

  def balance_the_balance(chips, currency)
    balance = Balance.find_by(currency: currency.currency)
    balance.amount += currency.amount
    balance.save
    Chip.all.each do |x|
      unless chips[x.value].nil?
        x.count -= chips[x.value].to_i
        x.save
      end
    end
  end
end

end
