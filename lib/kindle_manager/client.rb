module KindleManager
  class Client
    attr_accessor :session

    def initialize(options = {})
      @debug = options.fetch(:debug, false)
      @limit = options.fetch(:limit, nil)
      begin
        @client = AmazonAuth::Client.new
      rescue => e
        puts "Please setup credentials of amazon_auth gem with folloing its instruction."
        puts
        raise e
      end
    end

    def session
      @session ||= @client.session
    end

    def store
      # Create file store without session(session) by default
      @store ||= KindleManager::FileStore.new(nil, latest: true)
    end

    def setup_file_store_with_session
      @store = KindleManager::FileStore.new(session)
    end

    def fetch_kindle_list
      sign_in
      setup_file_store_with_session
      go_to_kindle_management_page
      begin
        load_next_kindle_list
      rescue => e
        byebug
        # retry ?
        puts e
      end
    end

    def load_kindle_books
      books = []
      store.list_html_files.each do |file|
        parser = KindleManager::ListParser.new(file)
        books += parser.book_list
      end
      books.uniq(&:asin)
    end

    def sign_in
      @client.sign_in
    end

    def go_to_kindle_management_page
      wait_for_selector('#shopAllLinks', 5)
      session.all('a').find{|e| e['href'] =~ %r{/gp/digital/fiona/manage/} }.click
    end

    def load_next_kindle_list
      wait_for_selector('.contentCount_myx')
      @current_loop = 0
      while @current_loop <= 12 # max attempts
        if @limit && @limit < number_of_fetched_books
          break
        elsif has_more_button?
          debug_print_page
          @current_loop = 0

          puts "Clicking 'Show More'"
          session.execute_script "window.scrollBy(0,-800)"
          show_more_button.click
          sleep 1
          raise('Clicking of more button may have failed') if has_more_button?
        else
          puts "Scrolling #{@current_loop}"
          session.execute_script "window.scrollBy(0,10000)"
        end
        sleep 5
        @current_loop += 1
      end
      snapshot_page
    end

    def quit
      session.driver.quit
    end

    def wait_for_selector(selector, seconds = 3)
      seconds.times { sleep(1) unless session.first(selector) }
    end

    def has_more_button?
      !!show_more_button
    end

    def show_more_button
      session.all('#contentTable_showMore_myx').find{|e| e['outerHTML'].match(/showmore_button/) }
    end

    def number_of_fetched_books
      m = session.first('.contentCount_myx').text.match(/(\d+) - (\d+)/)
      m.nil? ? nil : m[2].to_i
    end

    def loading?
      session.first('.myx-popover-loading-wrapper').present?
    end

    def snapshot_page
      store.record_page
      debug_print_page
    end

    def debug_print_page
      if @debug
        puts Time.current.strftime("%Y-%m-%d %H:%M:%S")
        puts "Loop: #{@current_loop}"
        puts session.first('.contentCount_myx').text if session.first('.contentCount_myx')
        puts
      end
    end
  end
end
