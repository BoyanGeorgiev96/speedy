# frozen_string_literal: true

module Speedy
  module Models
    module Clients
      class CODContractInfo < Speedy::Model
        field :money_transfer_allowed, type: :boolean
        field :cod_fiscal_receipt_allowed, type: :boolean
        field :has_cod_annex, type: :boolean
        field :international_cod_annexes,
              type: :array,
              of: Speedy::Models::Clients::CODInternationalAnnex
      end
    end
  end
end
