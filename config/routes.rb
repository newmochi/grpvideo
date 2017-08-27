Rails.application.routes.draw do
  resources :savings do
    collection do
      get :search
      get :registdb
      get :outputj
    end
    member do
      get :downloadimg
    end
  end

  root :to => 'top#index'
  get "sysope" => "top#sysope", as: "sysope"
  get "about" => "top#about", as: "about"
end
