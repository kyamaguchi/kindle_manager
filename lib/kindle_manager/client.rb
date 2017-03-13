module KindleManager
  class Client
    attr_accessor :page

    def initialize(options = {})
      begin
        @client = AmazonAuth::Client.new
      rescue => e
        puts "Please setup credentials of amazon_auth gem with folloing its instruction."
        puts
        raise e
      end
    end

    def load_kindle_list
      sign_in
      go_to_kindle_management_page
    end

    def sign_in
      @page = @client.sign_in
    end

    def go_to_kindle_management_page
      wait_for_selector('#shopAllLinks')
      page.within('#shopAllLinks') do
        page.find('a', text: 'コンテンツと端末の管理').click
      end
      page
    end

    def quit
      page.driver.quit
    end

    def wait_for_selector(selector, seconds = 3)
      seconds.times { sleep(1) unless page.first(selector) }
    end

  end
end
