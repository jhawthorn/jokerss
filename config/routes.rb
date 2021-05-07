Rails.application.routes.draw do
  root to: "home#index"
  resources :feeds do
    post "refresh", on: :member
  end
end
