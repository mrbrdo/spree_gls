Spree::Core::Engine.add_routes do
  namespace :admin do
    resource :dpd, controller: 'dpd', only: [:show, :create]
  end
end
