module Spree
  class DpdParcel < Spree::Base
    belongs_to :spree_shipment, class_name: 'Spree::Shipment'
    validates :tracking_code, presence: true

    has_one_attached :pdf_label
  end
end
