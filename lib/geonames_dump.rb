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
        # city name
        ret = GeonamesCity.joins("left join geonames_countries on country_code = iso").where("country ILIKE '%#{query}%' or name ILIKE '%#{query}%' or asciiname ILIKE '%#{query}%'  or alternatenames ILIKE '%#{query}% '")
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
