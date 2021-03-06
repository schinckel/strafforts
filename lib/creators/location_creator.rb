module Creators
  class LocationCreator
    def self.create_country(country)
      unless country.blank?
        Rails.logger.info("LocationCreator - Creating or updating country '#{country}'.")
        country = Country.where(name: country).first_or_create
        country.id
      end
    end

    def self.create_state(country_id, state)
      unless country_id.blank?
        Rails.logger.info("LocationCreator - Creating or updating state '#{state}'.")
        state = State.where(name: state, country_id: country_id).first_or_create
        state.id
      end
    end

    def self.create_city(country_id, city)
      unless country_id.blank?
        Rails.logger.info("LocationCreator - Creating or updating city '#{city}'.")
        city = City.where(name: city, country_id: country_id).first_or_create
        city.id
      end
    end
  end
end
