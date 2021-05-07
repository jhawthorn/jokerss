Rails.application.routes.draw do
  resources :feeds
  root to: "home#index"
end
