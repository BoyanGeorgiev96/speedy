# frozen_string_literal: true

require 'csv'

module Speedy
  module Services
    module Location
      class Country < Speedy::ServiceResource
        resource_path 'location/country'

        # POST `/location/country`
        def find(name: nil, iso_alpha2: nil, iso_alpha3: nil)
          response = post(body: {
            name: name, iso_alpha2: iso_alpha2, iso_alpha3: iso_alpha3
          }.compact)

          collection(response, Speedy::Models::Location::Country)
        end

        # POST `/location/country/{id}`
        def get(id)
          response = post(id.to_s)

          resource(response, Speedy::Models::Location::Country, key: :country)
        end

        # POST `/location/country/csv`
        def all
          response = post('csv')
          Speedy::Models::Location::Country.collection(csv_countries(response.body))
        end

        CSV_FIELDS = %i[
          id name name_en iso_alpha2 iso_alpha3 post_code_formats require_state address_type
          currency_code default_office_id street_types street_types_en complex_types
          complex_types_en site_nomen
        ].freeze

        private

        def csv_countries(body)
          CSV.parse(body.to_s).filter_map do |row|
            next if row.compact.empty? || row.first.to_s == 'id'

            country_attributes(row)
          end
        end

        def country_attributes(row)
          attributes = CSV_FIELDS.zip(row).to_h
          attributes[:post_code_formats] = csv_list(attributes[:post_code_formats])
          %i[street complex].each do |kind|
            attributes[:"#{kind}_types"] = nomenclature(
              attributes.delete(:"#{kind}_types"), attributes.delete(:"#{kind}_types_en")
            )
          end
          attributes
        end

        def csv_list(value)
          value.to_s.split(',').map(&:strip).reject(&:empty?)
        end

        def nomenclature(names, english_names)
          csv_list(names).zip(csv_list(english_names)).map { |name, name_en| { name: name, name_en: name_en } }
        end
      end
    end
  end
end
