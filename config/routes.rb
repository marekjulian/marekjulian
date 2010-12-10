ActionController::Routing::Routes.draw do |map|

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.signup '/signup', :controller => 'user/profiles', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'user/activations',
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
        collection.resource :uploader, :controlloer => 'uploader'
      end
      archive.resources :portfolios
      archive.resources :images
      archive.resource  :organizer
    end
    # cm.resources :archives, :has_many => [ :collections, :portfolios ]
  end

  map.resources :image_variants
  # map.resources :images

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
