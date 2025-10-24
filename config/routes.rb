Spree::Core::Engine.add_routes do
  namespace :admin, path: Spree.admin_path do
    resources :gls_orders
    resource :gls, controller: 'gls', only: [:show, :create] do
      member do
        get :download_label
      end
    end
  end
end
