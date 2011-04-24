ActionController::Routing::Routes.draw do |map|

    map.logout '/logout', :controller => 'sessions', :action => 'destroy'
    map.login '/login', :controller => 'sessions', :action => 'new'
    map.signup '/signup', :controller => 'user/profiles', :action => 'new'
    map.activate '/activate/:activation_code',
                 :controller => 'user/activations',
                 :action => 'activate', :activation_code => nil
    map.forgot_password '/forgot_password', :controller => 'user/passwords', :action => 'new'
    map.reset_password '/reset_password/:id', :controller => 'user/passwords', :action => 'edit', :id => nil
    map.resend_activation '/resend_activation', :controller => 'user/activations', :action => 'new'

    map.resource :user

    map.namespace :user do |user|
        user.resources :activations
        user.resources :invitations
        user.resources :passwords
        user.resources :profiles do |profiles|
            profiles.resources :password_settings
        end
    end

    map.resource  :session

    map.namespace :port do |port|
        port.root :controller => 'portfolios', :action => "show", :id => 1
        port.resources :portfolios, :only => :show do |portfolio|
            portfolio.resources :portfolio_collections, :only => :show
        end
    end

    map.namespace :cm do |cm|
        cm.root :controller => "root", :action => "index"
        cm.resources :archives do |archive|
            archive.resources :collections do |collection|
                collection.resources :images
                collection.resource :uploader, :controller => 'uploaders'
            end
            archive.resources :portfolios do |portfolio|
                portfolio.resources :portfolio_collections
            end
            archive.resources :images
            archive.resource  :organizer, :controller => 'organizer', :member => { :show => :get }
            archive.resource  :organizer, :controller => 'organizer', :member => { :update_preview_for_collections_tab => :get }
            archive.resource  :organizer, :controller => 'organizer', :member => { :update_preview_for_portfolios_tab => :get }
            archive.resource  :organizer, :controller => 'organizer', :member => { :update_preview_for_collection_instance_tab => :get }
            archive.resource  :organizer, :controller => 'organizer', :member => { :update_preview_for_collection_image_instance_tab => :get }
            archive.resource  :organizer, :controller => 'organizer', :member => { :update_preview_for_portfolio_instance_tab => :get }
            archive.resource  :organizer, :controller => 'organizer', :member => { :update_preview_for_portfolio_collection_instance_tab => :get }
            archive.resource  :organizer, :controller => 'organizer', :member => { :update_preview_content_for_collections_tab => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :update_preview_content_for_portfolios_tab => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :update_preview_content_for_collection_instance_tab => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :update_preview_content_for_collection_image_instance_tab => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :update_preview_content_for_portfolio_instance_tab => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :update_preview_content_for_portfolio_collection_instance_tab => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :create_new_collection_instance_tab => :get }
            archive.resource  :organizer, :controller => 'organizer', :member => { :create_new_collection_image_instance_tab => :get }
            archive.resource  :organizer, :controller => 'organizer', :member => { :create_new_portfolio_instance_tab => :get }
            archive.resource  :organizer, :controller => 'organizer', :member => { :create_new_portfolio_collection_instance_tab => :get }
            archive.resource  :organizer, :controller => 'organizer', :member => { :create_collection_form => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :create_collection => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :delete_collection_form => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :delete_collection => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :create_portfolio_form => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :create_portfolio => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :delete_portfolio_form => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :delete_portfolio => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :create_portfolio_collection_form => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :create_portfolio_collection => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :delete_portfolio_collection_form => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :delete_portfolio_collection => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :add_image_to_collection => :get }
            archive.resource  :organizer, :controller => 'organizer', :member => { :add_image_variant_to_collection_image => :get }
            archive.resource  :organizer, :controller => 'organizer', :member => { :replace_default_show_view_for_portfolio => :get }
            archive.resource  :organizer, :controller => 'organizer', :member => { :add_image_to_portfolio_collection_preview => :get }
            archive.resource  :organizer, :controller => 'organizer', :member => { :add_image_to_portfolio_collection => :get }
            archive.resource  :organizer, :controller => 'organizer', :member => { :add_image_show_view_to_portfolio_collection => :get }
            archive.resource  :organizer, :controller => 'organizer', :member => { :replace_default_show_view_for_portfolio_collection => :get }
            archive.resource  :organizer, :controller => 'organizer', :member => { :workspace_save_collection => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :workspace_save_collection_image => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :workspace_save_portfolio => :post }
            archive.resource  :organizer, :controller => 'organizer', :member => { :workspace_save_portfolio_collection => :post }
        end
    end

  map.resources :image_variants

  map.resources :users

  map.resources :archives do |archive|
    archive.resources :collections do |collection|
      collection.resource :gallery, :controller => 'gallery'
    end
  end

  map.root :controller => 'port/portfolios', :action => "show", :id => 1

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # See how all your routes lay out with "rake routes"

end
