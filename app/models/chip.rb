class Chip < ApplicationRecord

def self.convert_from_money(amount)
  chips = Chip.where('count > 0').to_a
  values = chips.pluck(:value)
  result = chips.map { |c| [c.value, 0] }.to_h

  if values.include?(amount)
    amount
  else
    while amount > 0 do
      values.each do |x|
        if amount >= x
          amount -= x
          result[x] += 1
        end
      end
    end
  end

  result
end

end
