Rails.application.routes.draw do
  root to: "home#index"
  resources :feeds do
    post :refresh, on: :member
    post :refresh, on: :collection, to: "feeds#refresh_all"
    get :timeline, on: :collection
  end
end
