require "geonames_dump/version"
require "geonames_dump/blocks"
require "geonames_dump/railtie" #if defined?(Rails)

module GeonamesDump
  def self.search(query, options = {})
    ret = nil

    type = options[:type] || :auto
    begin
      case type
      when :auto # return an array of features
        continent = GeonamesCountry.where("continent_s ILIKE '%#{query}%'").select("continent_s as name, 'continent' as tag_type").group("continent_s").limit(options[:limit])
        countries = GeonamesCountry.where("country ILIKE '%#{query}%'").select("country, continent_s, 'country' as tag_type").limit(options[:limit])
        
        states = GeonamesAdmin1.joins("left join geonames_countries on country_code = iso").where("name ILIKE '%#{query}%' or asciiname ILIKE '%#{query}%' or alternatenames ILIKE '%#{query}%'").select("geonames_features.*,geonames_countries.country as country,geonames_countries.continent_s as continent_s, 'states' as tag_type").limit(options[:limit])
        
        cities = GeonamesCity.joins("left join geonames_countries on country_code = iso").where("search_vector @@ plainto_tsquery('#{query}')").select("geonames_features.*,geonames_countries.country as country,geonames_countries.continent_s as continent_s, 'city' as tag_type")
        
        ret = continent + countries + states + cities 
      else # country, or specific type
        model = "geonames_#{type.to_s}".camelcase.constantize
        ret = model.search(query)
      end
    rescue NameError => e
      raise $!, "Unknown type for GeonamesDump, #{$!}", $!.backtrace
    end


    ret
  end
end
