Deface::Override.new(
  virtual_path: 'spree/admin/shared/_order_tabs',
  name: 'add_dpd_to_order_tabs',
  insert_bottom: 'ul.nav',
  text: <<-HTML

    <% if can? :update, @order %>
      <li data-hook='admin_order_tabs_dpd'>
        <%= link_to_with_icon 'shipping.svg',
          'DPD',
          edit_admin_dpd_order_url(@order),
          class: "\#{'active' if current == :dpd} nav-link" %>
      </li>
    <% end %>
  HTML
)
