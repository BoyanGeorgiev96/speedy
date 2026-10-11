# frozen_string_literal: true

require_relative 'speedy/version'
require_relative 'speedy/util'
require_relative 'speedy/error'
require_relative 'speedy/transport_error'
require_relative 'speedy/client_resources'
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
    autoload :Tracking, 'speedy/services/tracking'
    autoload :CourierServices, 'speedy/services/courier_services'
    autoload :Pickup, 'speedy/services/pickup'
    autoload :Clients, 'speedy/services/clients'
    autoload :Payments, 'speedy/services/payments'
    autoload :Location, 'speedy/services/location'
    autoload :Validation, 'speedy/services/validation'

    module Shipments
      autoload :Shipment, 'speedy/services/shipments/shipment'
    end

    module Location
      autoload :Office, 'speedy/services/location/office'
      autoload :Site, 'speedy/services/location/site'
      autoload :State, 'speedy/services/location/state'
      autoload :Country, 'speedy/services/location/country'
      autoload :Street, 'speedy/services/location/street'
      autoload :Complex, 'speedy/services/location/complex'
      autoload :Block, 'speedy/services/location/block'
      autoload :PointOfInterest, 'speedy/services/location/point_of_interest'
      autoload :Postcode, 'speedy/services/location/postcode'
    end

    module Validation
      autoload :Address, 'speedy/services/validation/address'
      autoload :General, 'speedy/services/validation/general'
    end
  end

  module Models
    autoload :Error, 'speedy/models/error'
    autoload :Response, 'speedy/models/response'

    module Tracking
      autoload :TrackedParcel, 'speedy/models/tracking/tracked_parcel'
      autoload :TrackedParcelOperation, 'speedy/models/tracking/tracked_parcel_operation'
      autoload :TrackedParcelOperationAdditionalInfo,
               'speedy/models/tracking/tracked_parcel_operation_additional_info'
      autoload :TrackedParcelOperationAdditionalInfoRecipient,
               'speedy/models/tracking/tracked_parcel_operation_additional_info_recipient'
      autoload :TrackedParcelOperationAdditionalInfoPredict,
               'speedy/models/tracking/tracked_parcel_operation_additional_info_predict'
      autoload :ExternalCarrierParcelNumberDetails,
               'speedy/models/tracking/external_carrier_parcel_number_details'
    end

    module Services
      autoload :CourierService, 'speedy/models/services/courier_service'
      autoload :ExtendedCourierService, 'speedy/models/services/extended_courier_service'
      autoload :AdditionalCourierService, 'speedy/models/services/additional_courier_service'
      autoload :AdditionalCourierServices, 'speedy/models/services/additional_courier_services'
    end

    module Pickup
      autoload :PickupOrder, 'speedy/models/pickup/pickup_order'
      autoload :TermsResponse, 'speedy/models/pickup/terms_response'
    end

    module Clients
      autoload :Client, 'speedy/models/clients/client'
      autoload :ContractInfo, 'speedy/models/clients/contract_info'
      autoload :SpecialDeliveryRequirements, 'speedy/models/clients/special_delivery_requirements'
      autoload :Requirement, 'speedy/models/clients/requirement'
      autoload :CODContractInfo, 'speedy/models/clients/cod_contract_info'
      autoload :CODInternationalAnnex, 'speedy/models/clients/cod_international_annex'
    end

    module Payments
      autoload :Payout, 'speedy/models/payments/payout'
      autoload :PayoutDetails, 'speedy/models/payments/payout_details'
    end

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
      autoload :UpdateShipmentResponse, 'speedy/models/shipments/update_shipment_response'
      autoload :Shipment, 'speedy/models/shipments/shipment'
      autoload :Sender, 'speedy/models/shipments/sender'
      autoload :Recipient, 'speedy/models/shipments/recipient'
      autoload :Content, 'speedy/models/shipments/content'
      autoload :Payment, 'speedy/models/shipments/payment'
      autoload :Parcel, 'speedy/models/shipments/parcel'
      autoload :ShipmentDelivery, 'speedy/models/shipments/shipment_delivery'
      autoload :CreatedShipmentParcel, 'speedy/models/shipments/created_shipment_parcel'
      autoload :ShipmentContent, 'speedy/models/shipments/shipment_content'
      autoload :ShipmentPayment, 'speedy/models/shipments/shipment_payment'
      autoload :ShipmentParcel, 'speedy/models/shipments/shipment_parcel'
      autoload :ShipmentParcelSize, 'speedy/models/shipments/shipment_parcel_size'
      autoload :GoodsItem, 'speedy/models/shipments/goods_item'
      autoload :ExternalCarrierParcelNumber, 'speedy/models/shipments/external_carrier_parcel_number'
      autoload :ShipmentDiscountCardId, 'speedy/models/shipments/shipment_discount_card_id'
      autoload :BankAccount, 'speedy/models/shipments/bank_account'
      autoload :CODPayment, 'speedy/models/shipments/cod_payment'
      autoload :ShipmentAdditionalServices, 'speedy/models/shipments/shipment_additional_services'
      autoload :ShipmentCODAdditionalService, 'speedy/models/shipments/shipment_cod_additional_service'
      autoload :ShipmentCODFiscalReceiptItem, 'speedy/models/shipments/shipment_cod_fiscal_receipt_item'
      autoload :ShipmentDeclaredValueAdditionalService,
               'speedy/models/shipments/shipment_declared_value_additional_service'
      autoload :ShipmentOBPD, 'speedy/models/shipments/shipment_obpd'
      autoload :ShipmentReturnAdditionalServices,
               'speedy/models/shipments/shipment_return_additional_services'
      autoload :ShipmentRODAdditionalService, 'speedy/models/shipments/shipment_rod_additional_service'
      autoload :ShipmentReturnReceiptAdditionalService,
               'speedy/models/shipments/shipment_return_receipt_additional_service'
      autoload :ShipmentElectronicReturnReceiptAdditionalService,
               'speedy/models/shipments/shipment_electronic_return_receipt_additional_service'
      autoload :ShipmentSWAPAdditionalService, 'speedy/models/shipments/shipment_swap_additional_service'
      autoload :ShipmentROPAdditionalService, 'speedy/models/shipments/shipment_rop_additional_service'
      autoload :ShipmentROPAdditionalServiceLine,
               'speedy/models/shipments/shipment_rop_additional_service_line'
      autoload :ShipmentReturnVoucherAdditionalService,
               'speedy/models/shipments/shipment_return_voucher_additional_service'
      autoload :MoneyTransferPremium, 'speedy/models/shipments/money_transfer_premium'
      autoload :ReturnAmounts, 'speedy/models/shipments/return_amounts'
      autoload :ShipmentAddress, 'speedy/models/shipments/shipment_address'
      autoload :ShipmentPhoneNumber, 'speedy/models/shipments/shipment_phone_number'
      autoload :ShipmentPrice, 'speedy/models/shipments/shipment_price'
      autoload :ShipmentPriceAmount, 'speedy/models/shipments/shipment_price_amount'
      autoload :ShipmentParcelRef, 'speedy/models/shipments/shipment_parcel_ref'
      autoload :ShipmentRecipient, 'speedy/models/shipments/shipment_recipient'
      autoload :ShipmentSender, 'speedy/models/shipments/shipment_sender'
      autoload :ShipmentService, 'speedy/models/shipments/shipment_service'
      autoload :SecondaryShipment, 'speedy/models/shipments/secondary_shipment'
      autoload :ShipmentParcelNumber, 'speedy/models/shipments/shipment_parcel_number'
      autoload :PrimaryShipment, 'speedy/models/shipments/primary_shipment'
      autoload :BarcodeInformation, 'speedy/models/shipments/barcode_information'
    end

    module Print
      autoload :ExtendedPrintResponse, 'speedy/models/print/extended_print_response'
      autoload :LabelInfo, 'speedy/models/print/label_info'
      autoload :LabelInfoResponse, 'speedy/models/print/label_info_response'
      autoload :PrintResponse, 'speedy/models/print/print_response'
      autoload :ParcelToPrintAdditionalBarcode, 'speedy/models/print/parcel_to_print_additional_barcode'
    end

    module Location
      autoload :FindOfficeResponse, 'speedy/models/location/find_office_response'
      autoload :FindSiteResponse, 'speedy/models/location/find_site_response'
      autoload :GetOfficeResponse, 'speedy/models/location/get_office_response'
      autoload :GetSiteResponse, 'speedy/models/location/get_site_response'
      autoload :Office, 'speedy/models/location/office'
      autoload :OfficeResult, 'speedy/models/location/office_result'
      autoload :OfficeWorkingTimeSchedule, 'speedy/models/location/office_working_time_schedule'
      autoload :RoutingInformation, 'speedy/models/location/routing_information'
      autoload :Tour, 'speedy/models/location/tour'
      autoload :Site, 'speedy/models/location/site'
      autoload :State, 'speedy/models/location/state'
      autoload :Country, 'speedy/models/location/country'
      autoload :Street, 'speedy/models/location/street'
      autoload :Complex, 'speedy/models/location/complex'
      autoload :Block, 'speedy/models/location/block'
      autoload :PointOfInterest, 'speedy/models/location/point_of_interest'
      autoload :Postcode, 'speedy/models/location/postcode'
      autoload :AddressNomenclatureType, 'speedy/models/location/address_nomenclature_type'
    end

    module Validation
      autoload :ValidationResponse, 'speedy/models/validation/validation_response'
    end

    module Tracking
      autoload :BulkTrackingDataFile, 'speedy/models/tracking/bulk_tracking_data_file'
    end
  end

  Address = Models::Common::Address
  ShipmentAddress = Models::Shipments::ShipmentAddress
  Office = Models::Location::Office
  State = Models::Location::State
end
