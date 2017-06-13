module KindleManager
  class BooksAdapter
    attr_accessor :store

    def initialize(options)
      @session = options.fetch(:session, nil)
      @options = options

      @debug = options.fetch(:debug, false)
      @limit = options.fetch(:limit, nil)
      @max_scroll_attempts = options.fetch(:max_scroll_attempts, 20)

      @store = KindleManager::FileStore.new(options.merge(session: @session))
      log "Directory for downloaded pages is #{store.base_dir}"
    end

    def fetch
      go_to_kindle_management_page
      begin
        load_next_kindle_list
      rescue => e
        byebug if defined?(Byebug)
        # retry ?
        puts e
      end
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
      while @current_loop <= @max_scroll_attempts
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

    def load
      books = []
      store.list_html_files.each do |file|
        parser = KindleManager::ListParser.new(file)
        books += parser.book_list
      end
      books.uniq(&:asin)
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