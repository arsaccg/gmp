Pmicg::Application.routes.draw do
 
  get "managers/new"
  devise_for :managers
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
   root 'management/projects#index'

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
  
  resources :units
  resources :inputs do
    collection do
      get 'add_input_unit'
      post 'add_input_unit'
    end
  end

  namespace :administration do
    resources :invoices
    resources :charges
    resources :advances
    resources :managers
    resources :inputcategories do
      collection do
        get 'feo_of_work'
        get 'feo_pdf'
        get 'get_input_detail'
      end
    end
  end

  namespace :management do
    get 'dashboard' => 'dashboard#index'
    post 'dashboard' => 'dashboard#index'
    resources :projects
    resources :extensionscontrols do
      collection do
        post 'approve'
        post 'disprove'
      end
    end
    resources :wbsitems do
      collection do
        get 'get_json_data'
        get 'add_items_to_wbs'
        get 'get_items_by_wbs_code'
        get 'get_items_by_budget'
        get 'get_credit'
        get 'get_items_from_project'
        get 'get_child'
        get 'get_items_json'
        get 'set_gantt'
        get 'graph_gantt'
        post 'save_gantt'
        get 'showbymonth_gantt'
        get 'showperitem_gantt'
        get 'show_measured'
        post 'add_phases_to_item'
        get 'add_phases_to_item'
      end
    end
    resources :budgets do 
      collection do 
        get 'load_elements'
        post 'load_elements'
        get 'get_cookies'
        get 'get_budget_by_project'
        get 'administrate_budget'
        get 'get_budgets'
        post 'get_budgets'
      end
      member do
        delete 'destroy_admin'
        get 'resume'
      end
    end
    resources :items
    resources :itembybudgets do 
      collection do
        get 'filter_by_budget'
      end
    end
    resources :inputbybudgetanditems do
      collection do
        get 'filter_by_budget_and_item'
      end
    end

    resources :itembywbses do
      collection do 
        get 'save_data'
        post 'save_data'
        get 'get_wbsitem_assigned'
        get 'add_data_item'
      end
    end

    resources :valorizations do
      member do 
        get 'newvalorization'
        get 'changevalorization'
        get 'finalize'
        get 'show_data'
        get 'change_data_ge'
        get 'change_data_u'
        get 'change_data_r'
        get 'change_data_rnd'
        get 'change_data_rnm'
        get 'change_data_da'
        get 'change_data_aom'
        get 'report'
      end
    end

    resources :valorizationitems do 
      collection do 
        get 'update_valorization_item'
      end
    end

    resources :managers
  end


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

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
