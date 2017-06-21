module KindleManager
  module Parsers
    module Common

      def parse_date(date_text)
        begin
          Date.parse(date_text)
        rescue ArgumentError => e
          m = date_text.match(/\A(?<year>\d{4})年(?<month>\d{1,2})月(?<day>\d{1,2})日\z/)
          Date.new(m[:year].to_i, m[:month].to_i, m[:day].to_i)
        end
      end
    end
  end
end
