Rails.application.routes.draw do
  root 'chips#index'

  resource :chips
end
