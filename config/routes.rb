Rails.application.routes.draw do
  root 'chips#index'

  resource :chips do
    collection do
      get 'add'
      post 'add_without_converting'
    end
  end
end
