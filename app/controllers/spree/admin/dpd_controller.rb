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
          custom_date: date_today ? Date.today : Date.tomorrow
        )
      end
      
      def create
        date =
          if params[:date] == 'today'
            Date.today
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
      
    private
    
      def parse_time_to_a(time_string)
        if time_string =~ /\A\s*(\d{1,2}):(\d{1,2})\s*\z/
          [$1.to_i, $2.to_i]
        else
          fail "Cannot parse time #{time_string}"
        end
      end
    end
  end
end