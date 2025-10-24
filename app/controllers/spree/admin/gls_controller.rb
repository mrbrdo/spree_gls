require 'ostruct'

module Spree
  module Admin
    class GlsController < Spree::Admin::BaseController
      def show
        date_today = DateTime.now.hour < 15
        @gls = OpenStruct.new(
          time_from: SpreeGls.config.pickup_time_from,
          time_to: SpreeGls.config.pickup_time_to,
          date_today: date_today,
          date_tomorrow: !date_today,
          date_custom: false,
          custom_date: date_today ? Date.current : Date.tomorrow
        )
      end

      def create
        date =
          if params[:date] == 'today'
            Date.current
          elsif params[:date] == 'tomorrow'
            Date.tomorrow
          elsif params[:custom_date].present?
            Date.parse(params[:custom_date])
          else
            fail "GLS carorder date not chosen!"
          end
        # convert date to 00:00 (beginning of day) in current timezone
        time_start = date.to_time(:local).to_datetime

        hours, mins = parse_time_to_a(params[:time_from])
        time_from = time_start + hours.hours + mins.minutes

        hours, mins = parse_time_to_a(params[:time_to])
        time_to = time_start + hours.hours + mins.minutes

        GlsClient.new.create_carorder(time_from, time_to)

        redirect_to admin_gls_path, notice: Spree.t('gls_carorder.created_successfully',
          date: time_from.strftime('%d.%m.%Y'),
          time_from: time_from.strftime('%H:%M'),
          time_to: time_to.strftime('%H:%M'))
      end

      def download_label
        shipment = Spree::Shipment.find_by(number: params[:shipment_number])
        order = shipment.order
        gls_parcel =
          Spree::GlsParcel.where(spree_shipment_id: shipment&.id).
          first_or_initialize(tracking_code: shipment&.tracking)

        if !gls_parcel.pdf_label.attached? && gls_parcel.tracking_code
          if pdf_data = GlsClient.new.get_pdf_label(gls_parcel.tracking_code)
            gls_parcel.pdf_label.attach({
              io: StringIO.new(pdf_data),
              filename: "gls-#{order.number}.pdf",
              content_type: 'application/pdf'
            })
            gls_parcel.save!
          end
        end

        if gls_parcel.pdf_label.attached?
          display_label(gls_parcel)
        else
          redirect_back fallback_location: spree.edit_admin_order_url(id: order.number), notice: "Could not generate GLS label!"
        end
      end

    private

      def parse_time_to_a(time_string)
        if time_string =~ /\A\s*(\d{1,2}):(\d{1,2})\s*\z/
          [$1.to_i, $2.to_i]
        else
          fail "Cannot parse time #{time_string}"
        end
      end

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
