module KindleManager
  module Parsers
    module Common
      extend ActiveSupport::Concern

      included do
        attr_accessor :fetched_at
      end

      def parse_date(date_text)
        begin
          Date.parse(date_text)
        rescue ArgumentError => e
          m = date_text.match(/\A(?<year>\d{4})年(?<month>\d{1,2})月(?<day>\d{1,2})日/)
          m = date_text.match(/(?<month>\d{1,2})月\D+(?<day>\d{1,2}),\D+(?<year>\d{4})/) if m.nil?
          raise("Failed to parse date [#{date_text}]") if m.nil?
          Date.new(m[:year].to_i, m[:month].to_i, m[:day].to_i)
        end
      end
    end
  end
end
