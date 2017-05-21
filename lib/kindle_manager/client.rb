module KindleManager
  class Client
    attr_accessor :session

    def initialize(options = {})
      @debug = options.fetch(:debug, false)
      @limit = options.fetch(:limit, nil)
      @options = options
      @client = AmazonAuth::Client.new(@options)
      extend(AmazonAuth::SessionExtension)
    end

    def session
      @session ||= @client.session
    end

    def store
      @store ||= KindleManager::FileStore.new(@options)
    end

    def setup_file_store
      store.session = session
      log "Directory for downloaded pages is #{store.base_dir}"
    end

    def fetch_kindle_list
      sign_in
      setup_file_store
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
      log "Visiting kindle management page"
      wait_for_selector('#shopAllLinks', wait_time: 5)
      3.times do
        link = links_for('#navFooter a').find{|link| link =~ %r{/gp/digital/fiona/manage/} }
        session.visit link
        wait_for_selector('.navHeader_myx')
        if session.first('.navHeader_myx')
          log "Page found '#{session.first('.navHeader_myx').text}'"
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

          log "Clicking 'Show More'"
          session.execute_script "window.scrollBy(0,-800)"
          show_more_button.click
          sleep 1
          raise('Clicking of more button may have failed') if has_more_button?
        else
          log "Loading books with scrolling #{@current_loop+1}"
          session.execute_script "window.scrollBy(0,10000)"
        end
        sleep fetching_interval
        @current_loop += 1
      end
      log "Stopped loading"
      snapshot_page
    end

    def quit
      session.driver.quit
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
      log "Current page [#{session.first('.contentCount_myx').text}]" if session.first('.contentCount_myx')
      store.record_page
      log "Saving page"
    end

    def fetching_interval
      @options.fetch(:fetching_interval, 3)
    end

    def log(message)
      return unless @debug
      puts "[#{Time.current.strftime('%Y-%m-%d %H:%M:%S')}] #{message}"
    end
  end
end
