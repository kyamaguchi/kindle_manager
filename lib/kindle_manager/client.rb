module KindleManager
  class Client
    include AmazonAuth::CommonExtension

    attr_accessor :adapter

    def initialize(options = {})
      @options = options
      @client = AmazonAuth::Client.new(@options)
      extend(AmazonAuth::SessionExtension)
    end

    def session
      @_session ||= @client.session
    end

    def sign_in
      @client.sign_in
    end

    def fetch_kindle_list
      sign_in
      set_adapter(:books, @options.merge(session: session))
      adapter.fetch
    end

    def fetch_kindle_highlights
      sign_in
      set_adapter(:highlights, @options.merge(session: session))
      adapter.fetch
    end

    def load_kindle_books
      set_adapter(:books, @options)
      adapter.load
    end

    def load_kindle_highlights
      set_adapter(:highlights, @options)
      adapter.load
    end

    def quit
      session.driver.quit
    end

    def set_adapter(type, options)
      @adapter = "KindleManager::#{type.to_s.camelize}Adapter".constantize.new(options.merge(sub_dir: type))
    end
  end
end
