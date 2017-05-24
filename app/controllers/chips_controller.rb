class ChipsController < ApplicationController
  def index
    @chips = Chip.all
    @currency = Balance.all
    puts @currency.as_json
  end
end
