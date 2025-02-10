Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  match "/", to: "home#index", via: [ :get, :post ]
  post "/create", to: "home#create"
end
