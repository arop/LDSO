Rails.application.routes.draw do

  get 'rio/:id' => 'rio#show', as: :rio, :id => /.*/

  get 'search' => 'searchrios#display'
  get 'profile' => 'profile#display'
  get 'home' => 'home#homepage'
  get 'contactos' => 'about#about'
  get 'documentos' => 'documentos_relacionados#documentos'

  get 'concelhos' => 'concelho#getConcelhosFromDistrito'

  resources :guardarios, only: [:index, :show, :new, :create, :destroy]
  resources :reports, only: [:index, :show, :new, :create, :destroy]
  resources :form_irrs
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  devise_for :users, :controllers => {registrations: 'registrations'}

  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  root 'home#homepage'

  namespace :api do
    namespace :v1 do
      resources :problems
      resources :services
      devise_scope :user do
        post "/sign_in", :to => 'sessions#create'
        post "/sign_up", :to => 'registrations#create'
        delete "/sign_out", :to => 'sessions#destroy'
      end
    end
    namespace :v2 do
      post "/form_irrs", :to => 'form_irrs#create'
      get "/form_irrs", :to => 'form_irrs#getMyForms'

      post "/guardarios", :to => 'guardarios#create'
      post "/reports", :to => 'reports#create'
    end
  end
end
