module KindleManager
  class BaseParser

    def initialize(filepath, options = {})
      @filepath = filepath
    end

    def doc
      @doc ||= Nokogiri::HTML(body)
    end

    def body
      @body ||= File.read(@filepath)
    end
  end
end
