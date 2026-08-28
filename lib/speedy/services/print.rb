# frozen_string_literal: true

module Speedy
  module Services
    class Print < Speedy::ServiceResource
      resource_path 'print'

      # POST /print
      def create_pdf(parcels:, format: nil, paper_size: nil, printer_name: nil, dpi: nil,
                     additional_waybill_sender_copy: nil)
        post(body: {
          parcels: parcels,
          format: format,
          paper_size: paper_size,
          printer_name: printer_name,
          dpi: dpi,
          additional_waybill_sender_copy: additional_waybill_sender_copy
        }.compact)
      end

      # POST /print/extended
      def create_pdf_extended(parcels:, format: nil, paper_size: nil, printer_name: nil, dpi: nil,
                              additional_waybill_sender_copy: nil)
        response = post('extended', body: {
          parcels: parcels,
          format: format,
          paper_size: paper_size,
          printer_name: printer_name,
          dpi: dpi,
          additional_waybill_sender_copy: additional_waybill_sender_copy
        }.compact)

        resource(response, Speedy::Models::Print::ExtendedPrintResponse)
      end

      # POST /print/labelInfo
      def label_info(parcel: nil, parcels: nil)
        response = post('labelInfo', body: { parcels: parcels || Array(parcel) }.compact)

        resource(response, Speedy::Models::Print::LabelInfoResponse)
      end
    end
  end
end
