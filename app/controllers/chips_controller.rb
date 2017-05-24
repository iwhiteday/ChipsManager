class ChipsController < ApplicationController
  def index
    @chips = Chip.all
    @currency = Balance.all
    puts @currency.as_json
  end

  def edit
  end

  def new
    @chips = Chip.all.pluck(:value)
  end

  def create
    @result = Balance.exchange_chips(params[:chips], 'usd')
  end

  def update
    currency = Balance.new(currency: 'usd', amount: params[:amount])
    @chips = Chip.convert_from_money currency
    if @chips.nil?
      @msg = 'Conversion failed, not enough chips to combine that amount'
    else
      @msg = 'Conversion succeed, please give this combination of chips to customer (and don\'t forget to smile)'
    end
  end
end
