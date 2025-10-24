class CreateSpreeGlsParcels < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_gls_parcels do |t|
      t.references :spree_shipment, null: false, foreign_key: true
      t.string :tracking_code

      t.timestamps
    end
  end
end
