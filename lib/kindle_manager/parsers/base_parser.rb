module KindleManager
  class BaseParser
    attr_accessor :fetched_at

    def initialize(filepath, options = {})
      @filepath = filepath

      @fetched_at = if File.basename(@filepath) =~ /\A\d{14}/
        Time.strptime(File.basename(@filepath)[0..14], KindleManager::FileStore::TIME_FORMAT_FOR_FILENAME)
      else
        File.ctime(@filepath)
      end
    end

    def doc
      @doc ||= Nokogiri::HTML(body)
    end

    def body
      @body ||= File.read(@filepath)
    end
  end
end
