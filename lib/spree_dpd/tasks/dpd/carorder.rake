require 'dpd_client'

namespace :dpd do
  desc 'Create DPD carorder'
  task carorder: :environment do
    puts "Creating DPD carorder..."
    date_choice = 2
    if DateTime.now.hour < 15
      puts "Choose:\n1.  Today\n2.  Tomorrow"
      if STDIN.gets.strip == '1'
        date_choice = 1
      end
    end
    time_from = DateTime.now.at_beginning_of_day + 12.hours
    time_to = DateTime.now.at_beginning_of_day + 14.hours + 30.minutes
    if date_choice == 2
      time_from += 1.day
      time_to += 1.day
    end
    DpdClient.new.create_carorder(time_from, time_to)
  end
end