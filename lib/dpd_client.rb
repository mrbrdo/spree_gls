require 'faraday'
require 'cgi'

class DpdClient
  class << self
    attr_reader :configuration
    def configure(config)
      @configuration = config.dup
    end
  end
  
  def req(url, data)
    body =
      data.merge(
        username: self.class.configuration[:username],
        password: self.class.configuration[:password]
      ).map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")
    Faraday.post("#{self.class.configuration[:api_url]}#{url}?#{body}", "")
  end
  
  def create_package(data)
    r = req("parcel/parcel_import", data)
    if r.status == 200
      if r.body
        json = JSON.load(r.body)
        if json['status'] == 'ok'
          return json['pl_number']
        else
          puts "DPD create_package error: #{r.body}"
        end
      end
    end
    nil
  end
  
  def create_carorder(time_from = DateTime.now.at_beginning_of_day + 1.day + 12.hours, time_to = DateTime.now.at_beginning_of_day + 1.day + 14.hours + 30.minutes)
    r = req("pickupdiff/pickupdiff_import",
      self.class.configuration[:sender_data].merge(
        date_from: time_from.strftime("%Y%m%d%H%M"),
        date_to: time_to.strftime("%Y%m%d%H%M"))
    )
    r.status == 200
  end
end
