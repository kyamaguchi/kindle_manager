module KindleManager
  class Client
    attr_accessor :session

    def initialize(options = {})
      @debug = options.fetch(:debug, false)
      @limit = options.fetch(:limit, nil)
      @options = options
      begin
        @client = AmazonAuth::Client.new(@options)
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
      @store ||= KindleManager::FileStore.new(@options)
    end

    def fetch_kindle_list
      sign_in
      store.session = session
      go_to_kindle_management_page
      begin
        load_next_kindle_list
      rescue => e
        byebug if defined?(Byebug)
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
      puts "Visiting kindle management page" if @debug
      wait_for_selector('#shopAllLinks', 5)
      3.times do
        session.all('a').find{|e| e['href'] =~ %r{/gp/digital/fiona/manage/} }.click
        wait_for_selector('.navHeader_myx', 5)
        if session.first('.navHeader_myx')
          puts "Page found '#{session.first('.navHeader_myx').text}'" if @debug
          break
        end
      end
    end

    def load_next_kindle_list
      wait_for_selector('.contentCount_myx')
      @current_loop = 0
      while @current_loop <= 12 # max attempts
        if @limit && @limit < number_of_fetched_books
          break
        elsif has_more_button?
          snapshot_page
          @current_loop = 0

          puts "Clicking 'Show More'" if @debug
          session.execute_script "window.scrollBy(0,-800)"
          show_more_button.click
          sleep 1
          raise('Clicking of more button may have failed') if has_more_button?
        else
          puts "Loading books with scrolling #{@current_loop+1}" if @debug
          session.execute_script "window.scrollBy(0,10000)"
        end
        sleep 5
        @current_loop += 1
      end
      puts "Stopped loading" if @debug
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
      re = (AmazonInfo.domain =~ /\.jp\z/ ? /(\d+)〜(\d+)/ : /(\d+) - (\d+)/)
      text = session.first('.contentCount_myx').text
      m = text.match(re)
      return m[2].to_i if m.present?
      raise("Couldn't get the number of fetched books [#{text}]")
    end

    def loading?
      session.first('.myx-popover-loading-wrapper').present?
    end

    def snapshot_page
      store.record_page
      if @debug
        puts "Saving page" + Time.current.strftime("%Y-%m-%d %H:%M:%S")
        puts session.first('.contentCount_myx').text if session.first('.contentCount_myx')
        puts
      end
    end
  end
end
