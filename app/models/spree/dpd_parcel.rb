module Spree
  class DpdParcel < Spree::Base
    belongs_to :spree_shipment, class_name: 'Spree::Shipment'
    validates :tracking_code, presence: true

    has_one_attached :pdf_label

    after_create :cleanup_old_parcels

    def cleanup_old_parcels
      Spree::DpdParcel.where("updated_at < ?", 1.month.ago).each(&:destroy!)
    end
  end
end
