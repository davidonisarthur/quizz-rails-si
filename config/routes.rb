Rails.application.routes.draw do
  post "/rails/active_storage/direct_uploads", to: "teacher/direct_uploads#create"

  scope "/:locale", locale: /pt-BR|en/ do
    root "home#index"

    resources :quiz_modules, param: :slug, only: [ :index ] do
      member do
        get  :play,   to: "quiz#show"
        post :answer, to: "quiz#answer"
        get  :result, to: "quiz#result"
      end
    end

    resources :users, only: [ :new, :create ]
    resource  :session, only: [ :new, :create, :destroy ]
    get  "/profile", to: "users#profile", as: :profile
    get  "/study",   to: "study#index",    as: :study
    get  "/study/:slug", to: "study#show",  as: :study_topic
    post "/study/:slug/progress", to: "study_progresses#create", as: :study_progress
    get  "/about",   to: "about#index",    as: :about
    post "/libras_mode/toggle", to: "libras_mode#toggle", as: :toggle_libras_mode

    namespace :teacher do
      root "dashboard#index"
      resources :classrooms, only: %i[index show create destroy] do
        resources :classroom_enrollments, only: %i[create destroy]
      end
      resources :quiz_modules do
        member do
          get :preview
          get :report
        end
        resources :questions, only: %i[new create edit update destroy] do
          member do
            post :duplicate
            patch :move
          end
        end
        resources :module_assignments, only: %i[create destroy]
      end
      resources :study_modules
      resources :study_modules, only: [] do
        resources :study_module_assignments, only: %i[create destroy]
      end
    end

    resources :teacher_access_requests, only: :create
    namespace :admin do
      resources :teacher_access_requests, only: :index do
        member { patch :approve; patch :reject }
      end
      resources :teacher_invitations, only: %i[index create]
    end
  end

  root "home#index", as: :root_redirect
end
