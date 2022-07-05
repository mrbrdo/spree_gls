Deface::Override.new(
  virtual_path:  'spree/admin/orders/_shipment',
  name:          'add_dpd_label_to_order_shipments',
  insert_bottom: 'div.stock-location h1',
  partial: 'spree/admin/orders/dpd_shipment_actions'
)
