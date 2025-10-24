Deface::Override.new(
  virtual_path:  'spree/admin/orders/_shipment',
  name:          'add_gls_label_to_order_shipments',
  insert_after: '.stock-location .stock-location-name',
  partial: 'spree/admin/orders/gls_shipment_actions'
)
