Rails.application.routes.draw do
  mount_devise_token_auth_for "User", at: "auth", controllers: {
    registrations: "auth/registrations"
  }
  namespace :api do
    namespace :v1 do
      resources :spots, only: %i[index show] do
        resources :spot_reviews, only: %i[index create]
      end
      resources :spot_reviews, only: %i[destroy] do
        member do
          post "likes", to: "likes#create"
          delete "likes", to: "likes#destroy"
        end
      end
      resources :tags, only: %i[index]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
