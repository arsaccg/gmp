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
    resources :cost_center_details do
      collection do
        post 'add_contractor_field'
      end
    end
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
        post 'add_modal_extra_operations'
        post 'add_more_row_form_extra_op'
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
        post 'add_modal_extra_operations'
        post 'add_more_row_form_extra_op'
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
    resources :order_service_extra_calculations
    resources :purchase_order_extra_calculations
    resources :extra_calculations
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
        post 'add_afp_item_field'
        post 'add_health_center_item_field'
        post 'add_familiar_item_field'
        post 'add_centerofstudy_item_field'
        post 'add_otherstudy_item_field'
        post 'add_experience_item_field'
        post 'show_workers'
        post 'show_workers_empleados'
        post 'part_worker'
        post 'part_contract'
      end
      member do
        get 'register'
        get 'approve'
        get 'cancel'
        get 'worker_pdf'
        post 'worker_pdf'
      end
    end
    resources :worker_contracts
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
        post 'show_part_people'
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
    resources :law_and_regulations do
      collection do
        post 'law_regulation'
      end
    end
    resources :technical_standards
    resources :type_of_technical_libraries
    resources :technical_libraries
    resources :download_softwares
  end

  namespace :documentary_control do
    resources :of_companies do
      collection do
        post 'of_companies'
      end
    end
    resources :type_of_companies
    resources :contest_documents do
      collection do
        post 'contest_docs'
      end
    end
    resources :type_of_contest_documents
    resources :contractual_documents do
      collection do
        post 'contractual_docs'
      end
    end
    resources :type_of_contractual_documents
    resources :book_works do
      collection do
        post 'book_works'
      end
    end
    resources :type_of_book_works
    resources :record_of_meetings do
      collection do
        post 'record_meetings'
      end
    end
    resources :type_of_record_of_meetings
    resources :received_letters do
      collection do
        post 'received_letters'
      end
    end
    resources :type_of_received_letters
    resources :issued_letters do
      collection do
        post 'last_code'
        post 'issued_letters'
      end    
    end
    resources :type_of_issued_letters
    resources :work_reports do
      collection do
        post 'work_reports'
      end
    end
    resources :type_of_work_reports
    resources :technical_files do
      collection do
        post 'technical_files'
      end
    end
    resources :type_of_technical_files
    resources :photo_of_works do
      collection do
        post 'display_photos'
      end
    end
    resources :flowcharts
  end

  namespace :administration do
    resources :payment_orders do
      collection do
        post 'get_info_from_provision'
      end
    end
    resources :document_provisions
    resources :provisions do
      collection do
        post 'display_orders'
        post 'display_details_orders'
        post 'puts_details_in_provision'
        post 'get_suppliers_by_type_order'
      end
    end
    resources :part_workers do
      collection do
        post 'show_part_workers'
      end
    end
    resources :health_centers
    resources :contract_types
    resources :provision_articles do
      collection do
        post 'puts_details_in_provision'
      end
    end
    resources :account_accountants do
      collection do
        get 'import'
        post 'do_import'
      end
    end

    resources :sub_dailies do
      collection do
        get 'import'
        post 'do_import'
      end
    end
  end

  namespace :payrolls do
    resources :concepts do
      collection do
        post 'add_subconcept'
      end
    end
    resources :afps
    resources :payrolls do 
      collection do
        post 'display_worker'
        post 'get_info'
        post 'generate_payroll'
        post 'show_workers'
        post 'add_concept'
      end
    end
    resources :payslips do
      collection do
        post 'get_cc'
        post 'get_sem'
      end
    end
  end
  
  namespace :general_expenses do
    resources :general_expenses do
      collection do
        post 'display_articles'
        post 'add_concept'
        post 'show_details'
        post 'report'
      end
    end
    resources :diverse_expenses_of_managements
  end
end
