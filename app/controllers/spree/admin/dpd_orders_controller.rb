module Spree
  module Admin
    class DpdOrdersController < OrdersController
      before_action :load_order, only: %i[
        edit
      ]

      def edit
        can_not_transition_without_customer_info
      end

      def create
        @order = scope.includes(:adjustments).find_by!(number: params[:order_number])
        @tracking_all = SpreeDpd::Shipment.for_order(
          params[:order_number],
          params[:weight_kg].to_s.gsub(',', '.').to_f)
        render 'edit'
      end
    end
  end
end
