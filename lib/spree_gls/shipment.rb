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
      @gls_api = GlsApi.new
    end

    def create_order_gls
      weight_kg = shipment.to_package.weight.to_f

      tracking_codes = create_order_gls_weight(shipment, weight_kg)

      Array(tracking_codes)
    end

    def create_order_gls_weight(shipment, weight_kg)
      order = shipment.order

      contact_name = "#{order.shipping_address.firstname} #{order.shipping_address.lastname}"
      name = order.shipping_address.company.presence || contact_name

      street = order.shipping_address.address1
      house_number = ""
      if order.shipping_address.address2.present?
        street += " " + order.shipping_address.address2
      end
      if street =~ /\A(.+)\s(\d+[a-z]?)\s*\z/
        street = $1
        house_number = $2
      end

      cod_amount = 0
      payment = shipment.order.payments.first
      if payment.payment_method.type == "Spree::PaymentMethod::PhysicalPayment"
        cod_amount = payment.amount.to_f.round(2)
      end

      config = GlsApi.configuration
      sender_address = config[:sender_address] || {}

      parcel_data = {
        ClientNumber: @gls_api.client_number.to_i,
        ClientReference: order.number,
        CODAmount: cod_amount,
        Content: '',
        Count: 1,
        DeliveryAddress: {
          City: order.shipping_address.city,
          ContactEmail: order.email,
          ContactName: contact_name,
          ContactPhone: order.shipping_address.phone,
          CountryIsoCode: order.shipping_address.country.iso,
          HouseNumber: house_number,
          Name: name,
          Street: street,
          ZipCode: order.shipping_address.zipcode
        },
        PickupAddress: {
          City: sender_address[:city],
          ContactEmail: sender_address[:email],
          ContactName: sender_address[:contact_name],
          ContactPhone: sender_address[:phone],
          CountryIsoCode: sender_address[:country_iso_code] || 'SI',
          HouseNumber: sender_address[:house_number],
          Name: sender_address[:name],
          Street: sender_address[:street],
          ZipCode: sender_address[:zip_code]
        },
        PickupDate: GlsApi.format_date(Date.tomorrow.to_time(:local) + 9.hours, :json),
        ServiceList: []
      }

      parcel_ids = @gls_api.prepare_labels(parcels: [parcel_data])
      parcel_ids.first
    end
  end
end
