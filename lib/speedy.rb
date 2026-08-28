# frozen_string_literal: true

require_relative 'speedy/version'
require_relative 'speedy/util'
require_relative 'speedy/error'
require_relative 'speedy/client'
require_relative 'speedy/camel_case_middleware'
require_relative 'speedy/service_resource'
require_relative 'speedy/resource_attributes'
require_relative 'speedy/model'
require_relative 'speedy/collection'

module Speedy
  module Services
    autoload :Calculation, 'speedy/services/calculation'
    autoload :Shipments, 'speedy/services/shipments'
    autoload :Print, 'speedy/services/print'
    autoload :Location, 'speedy/services/location'
    autoload :Validation, 'speedy/services/validation'

    module Shipments
      autoload :Shipment, 'speedy/services/shipments/shipment'
    end

    module Location
      autoload :Office, 'speedy/services/location/office'
      autoload :Site, 'speedy/services/location/site'
    end

    module Validation
      autoload :Address, 'speedy/services/validation/address'
    end
  end

  module Models
    autoload :Error, 'speedy/models/error'

    module Common
      autoload :Address, 'speedy/models/common/address'
    end

    module Calculation
      autoload :CalculationResult, 'speedy/models/calculation/calculation_result'
      autoload :AddressLocation, 'speedy/models/calculation/address_location'
      autoload :CalculationContent, 'speedy/models/calculation/calculation_content'
      autoload :CalculationRecipient, 'speedy/models/calculation/calculation_recipient'
      autoload :CalculationSender, 'speedy/models/calculation/calculation_sender'
      autoload :CalculationService, 'speedy/models/calculation/calculation_service'
    end

    module Shipments
      autoload :CreateShipmentResponse, 'speedy/models/shipments/create_shipment_response'
      autoload :CreatedShipmentParcel, 'speedy/models/shipments/created_shipment_parcel'
      autoload :ShipmentContent, 'speedy/models/shipments/shipment_content'
      autoload :ShipmentPayment, 'speedy/models/shipments/shipment_payment'
      autoload :ShipmentParcel, 'speedy/models/shipments/shipment_parcel'
      autoload :ShipmentAddress, 'speedy/models/shipments/shipment_address'
      autoload :ShipmentPhoneNumber, 'speedy/models/shipments/shipment_phone_number'
      autoload :ShipmentPrice, 'speedy/models/shipments/shipment_price'
      autoload :ShipmentPriceAmount, 'speedy/models/shipments/shipment_price_amount'
      autoload :ShipmentParcelRef, 'speedy/models/shipments/shipment_parcel_ref'
      autoload :ShipmentRecipient, 'speedy/models/shipments/shipment_recipient'
      autoload :ShipmentSender, 'speedy/models/shipments/shipment_sender'
      autoload :ShipmentService, 'speedy/models/shipments/shipment_service'
    end

    module Print
      autoload :ExtendedPrintResponse, 'speedy/models/print/extended_print_response'
      autoload :LabelInfo, 'speedy/models/print/label_info'
      autoload :LabelInfoResponse, 'speedy/models/print/label_info_response'
      autoload :PrintResponse, 'speedy/models/print/print_response'
    end

    module Location
      autoload :FindOfficeResponse, 'speedy/models/location/find_office_response'
      autoload :FindSiteResponse, 'speedy/models/location/find_site_response'
      autoload :GetOfficeResponse, 'speedy/models/location/get_office_response'
      autoload :GetSiteResponse, 'speedy/models/location/get_site_response'
      autoload :Office, 'speedy/models/location/office'
      autoload :OfficeWorkingTimeSchedule, 'speedy/models/location/office_working_time_schedule'
      autoload :Site, 'speedy/models/location/site'
    end

    module Validation
      autoload :ValidationResponse, 'speedy/models/validation/validation_response'
    end
  end

  Address = Models::Common::Address
  ShipmentAddress = Models::Shipments::ShipmentAddress
  Office = Models::Location::Office
end
