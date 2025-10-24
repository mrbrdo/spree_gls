Deface::Override.new(
  virtual_path: 'spree/admin/shared/_order_tabs',
  name: 'add_gls_to_order_tabs',
  insert_before: "erb[silent]:contains(':index, Spree::ReturnAuthorization')",
  text: <<-HTML

    <% if can? :update, @order %>
      <li data-hook='admin_order_tabs_gls'>
        <%= link_to_with_icon 'shipping.svg',
          'GLS',
          edit_admin_gls_order_url(@order),
          class: "\#{'active' if current == :gls} nav-link" %>
      </li>
    <% end %>
  HTML
)
