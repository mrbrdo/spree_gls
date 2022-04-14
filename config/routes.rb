Spree::Core::Engine.add_routes do
  namespace :admin, path: Spree.admin_path do
    resource :dpd, controller: 'dpd', only: [:show, :create]
  end
end
