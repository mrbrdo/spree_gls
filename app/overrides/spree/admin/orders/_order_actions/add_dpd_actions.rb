Deface::Override.new(
  virtual_path:  'spree/admin/orders/_order_actions',
  name:          'add_dpd_actions',
  insert_after: ':last-child',
  partial: 'spree/admin/orders/dpd_order_actions'
)
