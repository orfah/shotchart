module NBA
  module Parsers
    def find_named_result_set(json_obj, name)
      json_obj['resultSets'].each do |sub|
        return sub if sub['name'] == name
      end
    end

    def array_into_hash(array, headers, key_map={})
      hash = {}
      headers.each_with_index do |key, index|
        key = key.downcase
        key = key_map[key] if key_map.include?(key)
        hash[key.to_sym] = array[index]
      end
      hash
    end

    def json_headers

    end

    def snake_case(string)
      string.gsub(/([a-z])([A-Z])/, '\1_\2')
    end

    # this is in UTC, so it's off by 5-8 hours, but close enough for
    # what I'm doing.
    def date_to_unixtime(date)
      Date.parse(date).strftime('%s').to_i
    end

    def unixtime_to_date(utime)
      DateTime.strptime(utime.to_s,'%s')
    end
   
  end
end
