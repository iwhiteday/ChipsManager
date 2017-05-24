Rails.application.routes.draw do
  root 'chips#index'

  resources :chips
end
