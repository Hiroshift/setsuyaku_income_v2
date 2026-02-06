Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  # Define the root path route ("/")
  root 'home#index'
  post "new_income", to: "home#create"
  post "suggest", to: "home#suggest"
end
