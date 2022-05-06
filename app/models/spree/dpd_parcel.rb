require 'hexapdf'

module Spree
  class DpdParcel < Spree::Base
    belongs_to :spree_shipment, class_name: 'Spree::Shipment'
    validates :tracking_code, presence: true

    has_one_attached :pdf_label

    after_create :cleanup_old_parcels

    def cleanup_old_parcels
      Spree::DpdParcel.where("updated_at < ?", 1.month.ago).each(&:destroy!)
    end

    def pdf_label_translated(move_to)
      return unless pdf_label.attached?
      sio = StringIO.new
      pdf_label.blob.open do |file|
        doc = HexaPDF::Document.new(io: file)

        page = doc.pages.first

        matrix =
          if move_to == 'bl'
            HexaPDF::Content::TransformationMatrix.new(1, 0, 0, 1, 0, -page.box.top / 2)
          elsif move_to == 'br'
            HexaPDF::Content::TransformationMatrix.new(1, 0, 0, 1, page.box.right / 2, -page.box.top / 2)
          elsif move_to == 'tr'
            HexaPDF::Content::TransformationMatrix.new(1, 0, 0, 1, page.box.right / 2, 0)
          else
            HexaPDF::Content::TransformationMatrix.new(1, 0, 0, 1, 0, 0)
          end

        before_contents = doc.add({}, stream: " q #{matrix.to_a.join(' ')} cm ")
        after_contents = doc.add({}, stream: " Q ")
        page[:Contents] = [before_contents, *page[:Contents], after_contents]

        doc.write(sio)
      end
      sio.string
    end
  end
end
