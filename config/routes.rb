ArsacLogistica::Application.routes.draw do


  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'main#index'
  
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:,
  namespace :logistics do
    resources :unit_of_measurements
    resources :persons    
    resources :articles do 
      collection do
        post 'import'
        get 'import'
      end
    end
    resources :sectors
    resources :phases
    resources :subphases
    resources :cost_centers
    resources :delivery_orders do
      collection do
        post 'add_delivery_order_item_field'
      end
      member do
        get 'gorevise'
        get 'goapprove'
      end
    end
    resources :subcategories do
      collection do
        post 'get_subcategory_form_category'
      end
    end
    resources :categories    
    
  end

end
