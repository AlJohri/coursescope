CourseScope::Application.routes.draw do
  devise_for :users  

  namespace :api, defaults: {format: :json} do
    devise_scope :user do
      resource :session, only: [:create, :destroy]
    end
    resources :task_lists, only: [:index, :create, :update, :destroy, :show] do
      resources :tasks, only: [:index, :create, :update, :destroy]
    end
    resources :courses, only: [:index, :create, :update, :destroy, :show] do
      get 'scrape', :on => :collection
    end
  end

  root :to => "home#index"

  get '/dashboard' => 'templates#index'
  get '/task_lists/:id' => 'templates#index'
  get '/templates/:path.html' => 'templates#template', :constraints => { :path => /.+/  }
end
