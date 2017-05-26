class ChipsController < ApplicationController
  def index
    @chips = Chip.all
    @currency = Balance.all
  end

  def edit
  end

  def new
    @chips = Chip.all.pluck(:value)
  end

  def create
    chips = params[:chips]
    @result = Balance.exchange_chips(chips, 'usd')
    if @result.nil?
      @msg = 'Conversion failed, not enough money to convert that amount of chips'
      @dude_msg = 'be sure to say "i\'m sorry"'
    else
      @msg = 'Conversion succeed, please give this amount to customer'
      @dude_msg = 'and don\'t forget to smile'
    end
  end

  def update
    if params[:amount].empty?
      render 'edit'
    else
      balance = Balance.new(currency: 'usd', amount: params[:amount])
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

  def add
    @chips = Chip.all.pluck(:value)
  end

  def add_without_converting
    if params.key?('balance_required')
      balance = Balance.new(currency: 'usd', amount: params[:amount])
      Balance.add(balance)
    end
    if params.key?('chips_required')
      chips = params[:chips]
      chips.transform_keys!(&:to_i)
      chips.transform_values! { |value| -value.to_i}
      Chip.transaction do
        Chip.add(chips)
      end
    end
    redirect_to '/'
  end

end
