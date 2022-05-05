module Spree
  class ShipmentHandler
    class Dpd < Spree::ShipmentHandler
      def update_order_shipment_state
        order = @shipment.order
        new_state = OrderUpdater.new(order).update_shipment_state

        # If tracking code was manually set, don't create new DPD order
        if @shipment.tracking.blank? && new_state == 'shipped'
          tracking_all = SpreeDpd::Shipment.new(@shipment).create_order_dpd
          # TODO: there can be multiple tracking codes, handle this
          tracking = tracking_all.first
          @shipment.update tracking: tracking
        end

        order.update_columns(shipment_state: new_state, updated_at: Time.current)
      end

      protected
      def send_shipped_email
        # Delay email a bit because DPD tracking code is not working immediately
        Spree::ShipmentMailer.shipped_email(@shipment.id).deliver_later(wait: 1.hour)
      end
    end
  end
end
