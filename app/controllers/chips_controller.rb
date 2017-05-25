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
    chips = params[:chips]
    if params.key?('add_without_converting')
      chips.transform_keys!(&:to_i)
      chips.transform_values! { |value| -value.to_i}
      Chip.transaction do
        Chip.add(chips)
      end
      redirect_to '/'
    else
      @result = Balance.exchange_chips(chips, 'usd')
      if @result.nil?
        @msg = 'Conversion failed, not enough money to convert that amount of chips'
        @dude_msg = 'be sure to say "i\'m sorry"'
      else
        @msg = 'Conversion succeed, please give this amount to customer'
        @dude_msg = 'and don\'t forget to smile'
      end
    end

  end

  def update
    balance = Balance.new(currency: 'usd', amount: params[:amount] )
    puts balance.amount
    if params.key?('add_without_converting')
      Balance.add(balance)
      redirect_to '/'
    else
      @chips = Chip.convert_from_money balance
      if @chips.nil?
        @msg = 'Conversion failed, not enough chips to combine that amount'
        @dude_msg = 'be sure to say "i\'m sorry"'
      else
        @msg = 'Conversion succeed, please give this combination of chips to customer'
        @dude_msg = 'and don\'t forget to smile'
      end
    end
  end
end
