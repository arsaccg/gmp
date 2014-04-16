ArsacLogistica::Application.routes.draw do

  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'logistics/main#index'
  
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
    resources :center_of_attentions
    resources :financial_variables
    resources :articles do
      member do
        get 'show_article'
        post 'show_article'
      end
      collection do
        post 'import'
        get 'import'
      end
    end
    resources :sectors
    resources :phases do
      collection do
        get 'addsub'
        
      end
      member do
        get 'editsub' 
      end
    end
    resources :subphases
    resources :companies
    resources :cost_centers
    resources :type_entities
    resources :type_of_articles
    resources :entities
    resources :main do
      member do
        post 'show_panel'
      end
    end
    resources :delivery_orders do
      collection do
        post 'add_delivery_order_item_field'
        post 'show_rows_delivery_orders'
      end
      member do
        get 'gorevise'
        get 'goapprove'
        get 'goissue'
        get 'goobserve'
        get 'delivery_order_pdf'
        post 'delivery_order_pdf'
        get 'show_tracking_orders'
        delete 'delete'
      end
    end
    resources :purchase_orders do
      collection do
        post 'add_items_from_delivery_orders'
        post 'more_items_from_delivery_orders'
        post 'show_rows_purchase_orders'
      end
      member do
        put 'show_delivery_order_item_field'
        get 'gorevise'
        get 'goapprove'
        get 'goissue'
        get 'goobserve'
        get 'purchase_order_pdf'
        post 'purchase_order_pdf'
        delete 'delete'
      end
    end
    resources :order_of_services do
      collection do
        post 'add_order_service_item_field'
        post 'show_rows_orders_service'
      end
      member do
        get 'gorevise'
        get 'goapprove'
        get 'goissue'
        get 'goobserve'
        get 'order_service_pdf'
        post 'order_service_pdf'
        delete 'delete'
      end
    end
    resources :subcategories do
      collection do
        post 'get_subcategory_form_category'
      end
    end
    resources :specifics do
      collection do
        post 'get_subcategory_form_category'
        post 'get_specific_from_subcategory'
      end
    end
    resources :categories    
    resources :suppliers
    resources :method_of_payments
    resources :money do
      collection do
        get 'add_exchange_of_rate'
        
      end
    end
    resources :exchange_of_rates
    resources :warehouses
    resources :formats
    resources :documents
    resources :stock_inputs do
      collection do
        post 'add_items_from_purchase_order'
      end
      member do
        put 'show_purchase_order_item_field'
      end
    end

  end

  namespace :biddings do
    resources :works
    resources :work_partners
    resources :professionals
    resources :trainings
    resources :certificates do
      collection do
        post 'get_component_from_work'
      end
    end
    resources :components
    resources :charges
    resources :majors
  end

end