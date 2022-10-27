Deface::Override.new(
  virtual_path:  'spree/admin/orders/_shipment',
  name:          'add_dpd_label_to_order_shipments',
  insert_after: '.stock-location .stock-location-name',
  partial: 'spree/admin/orders/dpd_shipment_actions'
)
