Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  # Define the root path route ("/")
  root 'home#index'
  get "welcome", to: "home#welcome"
  post "new_income", to: "home#create"
  post "suggest", to: "home#suggest"
  get "history", to: "history#index"
  delete "recordings/:id", to: "history#destroy", as: :recording
end
