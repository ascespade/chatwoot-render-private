# Clinic Feature Routes
# Include this file in config/routes.rb

Rails.application.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :accounts, only: [] do
        scope module: :accounts do
          namespace :clinic do
            resources :doctors, only: [:index, :show, :create, :update, :destroy]
            resources :appointments, only: [:index, :show, :create, :update, :destroy] do
              collection do
                get :today
                get :upcoming
              end
              member do
                post :confirm
                post :complete
                post :cancel
              end
            end
            resource :dashboard, only: [:show]
          end
        end
      end
    end
  end
end

