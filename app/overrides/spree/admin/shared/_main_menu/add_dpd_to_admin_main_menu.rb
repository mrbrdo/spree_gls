Deface::Override.new(
  virtual_path: 'spree/admin/shared/_main_menu',
  name: 'add_dpd_to_admin_main_menu',
  insert_before: '#sidebarStock',
  text: <<-HTML
          <ul class="nav nav-sidebar border-bottom" id="sidebarDpd">
            <%= tab :dpd, url: admin_dpd_path, icon: 'box.svg' %>
          </ul>
  HTML
)