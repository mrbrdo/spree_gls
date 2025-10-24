module SpreeGls
  class Shipment
    def self.for_order(order_number, weight_kg)
      order = ::Spree::Order.find_by(number: order_number)
      shipment = order.shipments.first
      new(shipment).create_order_gls_weight(shipment, weight_kg)
    end

    attr_reader :shipment
    def initialize(shipment)
      @shipment = shipment
      @gls_client = GlsClient.new
    end

    def create_order_gls
      weight_kg = shipment.to_package.weight.to_f

      tracking_codes = create_order_gls_weight(shipment, weight_kg)

      Array(tracking_codes)
    end

    def create_order_gls_weight(shipment, weight_kg)
      order = shipment.order

      contact_person = nil
      name1 = order.shipping_address.company
      name2 = "#{order.shipping_address.firstname} #{order.shipping_address.lastname}"
      if name1.blank?
        name1 = name2
        name2 = ""
      else
        contact_person = name2
      end

      street = order.shipping_address.address1
      if order.shipping_address.address2.present?
        # some people write street number into address2
        street += " " + order.shipping_address.address2
      end
      rPropNum = ""
      if street =~ /\A(.+)\s(\d+[a-z]?)\s*\z/
        street = $1
        rPropNum = $2
      end

      @gls_client.create_package(
        name1: name1[0,35],
        name2: name2[0,35],
        contact: contact_person,
        street: street,
        rPropNum: rPropNum, # street number
        city: order.shipping_address.city,
        country: order.shipping_address.country.iso,
        pcode: order.shipping_address.zipcode,
        email: order.email,
        phone: order.shipping_address.phone,
        weight: weight_kg.to_s, # delimited by dot
        order_number: order.number, # reference
        parcel_type: "D", # GLS Classic
        num_of_parcel: "1"
      )
    end
  end
end
