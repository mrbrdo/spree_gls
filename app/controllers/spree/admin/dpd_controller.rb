require 'ostruct'

module Spree
  module Admin
    class DpdController < Spree::Admin::BaseController
      def show
        date_today = DateTime.now.hour < 15
        @dpd = OpenStruct.new(
          time_from: '12:00',
          time_to: '14:30',
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
            fail "DPD carorder date not chosen!"
          end
        # convert date to 00:00 (beginning of day) in current timezone
        time_start = date.to_time(:local).to_datetime

        hours, mins = parse_time_to_a(params[:time_from])
        time_from = time_start + hours.hours + mins.minutes

        hours, mins = parse_time_to_a(params[:time_to])
        time_to = time_start + hours.hours + mins.minutes

        DpdClient.new.create_carorder(time_from, time_to)

        redirect_to admin_dpd_path, notice: Spree.t('dpd_carorder.created_successfully',
          date: time_from.strftime('%d.%m.%Y'),
          time_from: time_from.strftime('%H:%M'),
          time_to: time_to.strftime('%H:%M'))
      end

      def download_label
        order = Spree::Order.find_by(number: params[:order_number])
        shipment = order.shipments.first
        dpd_parcel =
          Spree::DpdParcel.where(spree_shipment_id: shipment&.id).
          first_or_initialize(tracking_code: shipment&.tracking)

        if !dpd_parcel.pdf_label.attached? && dpd_parcel.tracking_code
          if pdf_data = DpdClient.new.get_pdf_label(dpd_parcel.tracking_code)
            dpd_parcel.pdf_label.attach({
              io: StringIO.new(pdf_data),
              filename: "dpd-#{order.number}.pdf",
              content_type: 'application/pdf'
            })
            dpd_parcel.save!
          end
        end

        if dpd_parcel.pdf_label.attached?
          display_label(dpd_parcel)
        else
          redirect_back fallback_location: spree.edit_admin_order_url(id: order.number), notice: "Could not generate DPD label!"
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

      def display_label(dpd_parcel)
        if params[:label_placement].in?(['tr', 'bl', 'br'])
          order = dpd_parcel.spree_shipment.order
          send_data(
            dpd_parcel.pdf_label_translated(params[:label_placement]),
            filename: "dpd-#{order.number}.pdf",
            type: 'application/pdf',
            disposition: 'attachment'
          )
        else
          redirect_to main_app.url_for(dpd_parcel.pdf_label)
        end
      end
    end
  end
end
