module Spree
  class ShipmentHandler
    class Gls < Spree::ShipmentHandler
      def update_order_shipment_state
        super

        # If tracking code was manually set, don't create new GLS order
        if @shipment.state == 'shipped' && (@shipment.tracking.blank? || @shipment.tracking == 'gls')
          tracking_all = SpreeGls::Shipment.new(@shipment).create_order_gls
          # TODO: there can be multiple tracking codes, handle this
          tracking = tracking_all.first
          @shipment.update tracking: tracking
        end
      end

      protected
      def send_shipped_email
        if @shipment.tracking != 'shipped'
          # Delay email a bit because GLS tracking code is not working immediately
          Spree::ShipmentMailer.shipped_email(@shipment.id).deliver_later(wait: 1.hour)
        end
      end
    end
  end
end
