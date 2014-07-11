ArsacLogistica::Application.routes.draw do


  devise_for :users, :controllers => {:registrations => "users/registrations"}
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  
  root 'main#index'
  get 'show_panel/:id' => 'main#show_panel', as: :show_panel_main
  get 'inbox_task' => 'main#inbox_task', as: :inbox_task_main
  get 'display_general_table_messages' => 'main#display_general_table_messages', as: :display_general_table_messages
  get 'display_table_messages_os' => 'main#display_table_messages_os', as: :display_table_messages_os
  get 'display_table_messages_oc' => 'main#display_table_messages_oc', as: :display_table_messages_oc
  get 'display_table_messages_ose' => 'main#display_table_messages_ose', as: :display_table_messages_ose
  get 'management_dashboard' => 'main#management_dashboard', as: :management_dashboard
  get 'home' => 'main#home'
  post 'home' => 'main#home'
  
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
        post 'update_profile'
      end
    end
    resources :theoretical_values do
      collection do
        post 'partial_table'
      end
    end
    resources :banks
    resources :center_of_attentions
    resources :financial_variables
    resources :articles do
      member do
        get 'show_article'
        post 'show_article'
        delete 'delete_specific'
        get 'edit_specific'
        post 'update_specific'
      end
      collection do
        post 'display_articles'
        get 'specifics_articles'
        post 'create_specific'
        get 'new_specific'
        post 'json_specifics_articles'
        post 'json_articles_from_specific_article_table'
        post 'import'
        get 'import'
        post 'display_articles_specific'
      end
    end
    resources :sectors
    resources :phases do
      collection do
        get 'addsub'
        get 'getSpecificsPhases'
        post 'import'
        get 'import'
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
    resources :delivery_orders do
      collection do
        post 'add_delivery_order_item_field'
        post 'display_articles'
        post 'show_rows_delivery_orders'
        get 'show_tracking_orders'
      end
      member do
        get 'gorevise'
        get 'goapprove'
        get 'goissue'
        get 'goobserve'
        get 'delivery_order_pdf'
        post 'delivery_order_pdf'
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
        post 'display_articles'
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
    resources :subcategories
    resources :specifics
    resources :categories do
      collection do
        post 'get_subcategory_form_category'
        post 'get_specific_from_subcategory'
      end
    end    
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
        post 'add_items_from_pod'
        post 'partial_select_per_warehouse'
        post 'partial_table_per_warehouse'
      end
    end
    resources :working_groups
  end

  namespace :biddings do
    resources :works do
      collection do
        post 'more_documents'
        post 'get_components_by_speciality'
        get 'calendar'
      end
    end
    resources :work_partners
    resources :other_works
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
    resources :graphs do
      get 'do_graph'
      post 'do_graph'
    end
    resources :inventories do
      collection do
        post 'show_rows_results'
      end
      member do
        get 'show_rows_results_pdf'
        get 'show_group_results_pdf'
      end
    end
    resources :reportofthemonths
  end

  namespace :production do
    resources :position_workers
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
    resources :sc_valuations do
      collection do
        post 'get_report'
        post 'part_work'
        post 'part_people'
        post 'part_equipment'        
      end
      member do
        get 'approve'
      end
    end
    resources :machinery_reports do
      collection do
        post 'get_report'
      end
    end
    resources :equipment_reports do
      collection do
        post 'get_report'
        post 'complete'
      end
    end
    resources :weekly_reports do
      collection do
        post 'get_report'
      end
    end
    resources :valuation_of_equipments do
      collection do
        post 'get_report'
        post 'part_equipment'
        post 'report_of_equipment'
      end
      member do
        get 'approve'
      end
    end
    resources :part_works do
      collection do
        post 'add_more_article'
        post 'display_articles'
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
        post 'get_unit'
        post 'add_more_register'
        post 'display_fuel_articles'
        post 'show_part_of_equipments'
      end
    end
    resources :working_groups
    resources :subcontract_equipment_details do
      collection do
        post 'get_component_from_article'
        post 'display_articles'
      end
    end
    resources :rental_types
    resources :subcontract_equipments do
      collection do
        post 'add_more_advance'
      end
    end
    resources :subcontracts do
      collection do
        post 'add_more_article'
        post 'add_more_advance'
        post 'display_articles'
      end
    end
    namespace :daily_works do
      resources :daily_workers do
        collection do
          post 'search_daily_work'
          post 'search_weekly_work'
        end
      end

      resources :weekly_workers do
        collection do
          post 'graph'
          post 'graph_week'
          post 'search_daily_work'
          post 'weekly_table'
        end
        member do
          get 'approve'
        end
      end
    end
  end

  namespace :libraries do
    resources :interest_links
    resources :type_of_law_and_regulations
    resources :law_and_regulations
    resources :technical_standards
    resources :type_of_technical_libraries
    resources :technical_libraries
    resources :download_softwares
  end

  namespace :documentary_control do
    resources :of_companies
    resources :type_of_companies
    resources :contest_documents
    resources :type_of_contest_documents
    resources :contractual_documents
    resources :type_of_contractual_documents
    resources :book_works
    resources :type_of_book_works
    resources :record_of_meetings
    resources :type_of_record_of_meetings
    resources :received_letters
    resources :type_of_received_letters
    resources :issued_letters
    resources :type_of_issued_letters
    resources :work_reports
    resources :type_of_work_reports
    resources :technical_files
    resources :type_of_technical_files
    resources :photo_of_works
    resources :flowcharts
  end
end