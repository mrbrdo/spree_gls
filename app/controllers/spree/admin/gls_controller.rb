module Spree
  module Admin
    class GlsController < Spree::Admin::BaseController
      def download_label
        shipment = Spree::Shipment.find_by(number: params[:shipment_number])
        order = shipment.order
        gls_parcel =
          Spree::GlsParcel.where(spree_shipment_id: shipment&.id).
          first_or_initialize(tracking_code: shipment&.tracking)

        if !gls_parcel.pdf_label.attached? && gls_parcel.tracking_code
          begin
            gls_api = GlsApi.new
            pdf_data = gls_api.get_printed_labels(parcel_ids: [gls_parcel.tracking_code.to_i])
            gls_parcel.pdf_label.attach({
              io: StringIO.new(pdf_data),
              filename: "gls-#{order.number}.pdf",
              content_type: 'application/pdf'
            })
            gls_parcel.save!
          rescue GLSAPIError => e
            Rails.logger.error "GLS get_printed_labels error: #{e.message}"
          end
        end

        if gls_parcel.pdf_label.attached?
          display_label(gls_parcel)
        else
          redirect_back fallback_location: spree.edit_admin_order_url(id: order.number), notice: "Could not generate GLS label!"
        end
      end

    private

      def display_label(gls_parcel)
        if params[:label_placement].in?(['tr', 'bl', 'br'])
          order = gls_parcel.spree_shipment.order
          send_data(
            gls_parcel.pdf_label_translated(params[:label_placement]),
            filename: "gls-#{order.number}.pdf",
            type: 'application/pdf',
            disposition: 'attachment'
          )
        else
          redirect_to main_app.url_for(gls_parcel.pdf_label)
        end
      end
    end
  end
end
