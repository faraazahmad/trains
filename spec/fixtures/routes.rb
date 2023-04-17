Rails.application.routes.draw do
  resources :cats

  get "/boxes", to: "BoxController#index", as: "list_boxes"

  scope "/admin" do
    resources :users
    resources :cars
  end

  resources :magazines do
    resources :ads
  end
end
