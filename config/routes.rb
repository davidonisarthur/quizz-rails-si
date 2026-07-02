Rails.application.routes.draw do
  scope "/:locale", locale: /pt-BR|en/ do
    root "home#index"

    resources :quiz_modules, param: :slug, only: [:index] do
      member do
        get  :play,   to: "quiz#show"
        post :answer, to: "quiz#answer"
        get  :result, to: "quiz#result"
      end
    end

    resources :users, only: [:new, :create]
    resource  :session, only: [:new, :create, :destroy]
    get  "/profile", to: "users#profile", as: :profile
    get  "/ranking", to: "ranking#index",  as: :ranking
    post "/libras_mode/toggle", to: "libras_mode#toggle", as: :toggle_libras_mode
  end

  root "home#index", as: :root_redirect
end
