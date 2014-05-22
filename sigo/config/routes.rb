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
    resources :persons do
      collection do
        post 'getCostCentersPerCompany'
      end
    end
    resources :banks
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
    resources :cost_centers do
      member do
        get 'update_timeline'
        get 'select_warehouses'
      end
    end
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
        post 'get_exchange_rate_per_date'
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
        post 'show_rows_stock_inputs'
        post 'add_items_from_pod'
        post 'more_items_from_pod'
      end
      member do
        put 'show_purchase_order_item_field'
      end
    end
    resources :stock_outputs do
      collection do
        post 'show_rows_stock_inputs'
        post 'add_stock_input_item_field'
      end
    end
    resources :working_groups
  end

  namespace :biddings do
    resources :works do
      collection do
        post 'more_documents'
        post 'get_components_by_speciality'
      end
    end
    resources :work_partners
    resources :professionals do
      collection do
        post 'get_component_from_work'
        post 'more_dates'
        post 'more_certificates'
        post 'more_trainings'
      end
    end
    resources :trainings
    resources :certificates
    resources :components
    resources :charges
    resources :majors
  end

  namespace :reports do
    resources :inventories do
      collection do
        post 'show_rows_results'
      end
      member do
        get 'show_rows_results_pdf'
        get 'show_group_results_pdf'
      end
    end
  end

  namespace :production do
    resources :subcontract_inputs do
      collection do
        post 'get_articles'
      end
    end
    resources :workers do
      collection do
        post 'add_worker_item_field'
      end
    end
    resources :analysis_of_valuations do
      collection do
        post 'get_report'
        post 'frontChief'
        post 'executor'
      end
    end
    resources :part_works do
      collection do
        post 'add_more_article'
      end
    end
    resources :part_people do
      collection do
        post 'add_more_worker'
      end
    end
    resources :category_of_workers
    resources :part_of_equipments do
      collection do
        post 'get_equipment_form_subcontract'
        post 'add_more_register'
      end
    end
    resources :working_groups
    resources :subcontract_equipment_details do
      collection do
        post 'get_component_from_article'
      end
    end
    resources :rental_types
    resources :subcontract_equipments
    resources :subcontracts do
      collection do
        post 'add_more_article'
      end
    end
    namespace :daily_works do
      resources :daily_workers do
        collection do
          post 'search_daily_work'
          post 'search_weekly_work'
        end
      end

      resources :weekly_workers
    end
  end

end

  
