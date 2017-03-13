module KindleManager
  class Client
    attr_accessor :page, :store

    def initialize(options = {})
      @debug = options.fetch(:debug, false)
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
      setup_file_store
      go_to_kindle_management_page
      begin
        load_next_kindle_list
      rescue => e
        byebug
        # retry ?
        puts e
      end
    end

    def sign_in
      @page = @client.sign_in
    end

    def setup_file_store
      @store = KindleManager::FileStore.new(page)
    end

    def go_to_kindle_management_page
      wait_for_selector('#shopAllLinks')
      page.within('#shopAllLinks') do
        page.find('a', text: 'コンテンツと端末の管理').click
      end
      page
    end

    def load_next_kindle_list
      wait_for_selector('.contentCount_myx')
      @current_loop = 0
      while @current_loop <= 12 # max attempts
        if has_more_button?
          debug_print_page
          @current_loop = 0

          puts "Clicking もっと表示"
          page.execute_script "window.scrollBy(0,-800)"
          page.click_on('もっと表示')
          sleep 1
          raise('Clicking of more button may have failed') if has_more_button?
        else
          puts "Scrolling #{@current_loop}"
          page.execute_script "window.scrollBy(0,10000)"
        end
        sleep 5
        @current_loop += 1
      end
      debug_print_page
    end

    def quit
      page.driver.quit
    end

    def wait_for_selector(selector, seconds = 3)
      seconds.times { sleep(1) unless page.first(selector) }
    end

    def has_more_button?
      page.all('#contentTable_showMore_myx').map(&:text).include?('もっと表示')
    end

    def loading?
      page.first('.myx-popover-loading-wrapper').present?
    end

    def debug_print_page
      if @debug
        store.record_page
        puts Time.current.strftime("%Y-%m-%d %H:%M:%S")
        puts "Loop: #{@current_loop}"
        puts page.first('.contentCount_myx').text if page.first('.contentCount_myx')
        puts
      end
    end
  end
end
