module KindleManager
  class Client
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
      @adapter = BooksAdapter.new(@options.merge(session: session))
      adapter.fetch
    end

    def load_kindle_books
      @adapter = BooksAdapter.new(@options)
      adapter.load
    end

    def quit
      session.driver.quit
    end
  end
end
