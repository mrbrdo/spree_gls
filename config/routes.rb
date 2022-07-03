Spree::Core::Engine.add_routes do
  namespace :admin, path: Spree.admin_path do
    resources :dpd_orders
    resource :dpd, controller: 'dpd', only: [:show, :create] do
      member do
        get :download_label
      end
    end
  end
end
