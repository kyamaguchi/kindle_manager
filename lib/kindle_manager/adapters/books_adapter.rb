module KindleManager
  class BooksAdapter < BaseAdapter
    URL_FOR_KINDLE_CONTENTS = 'https://www.amazon.co.jp/hz/mycd/digital-console/contentlist/booksAll/dateDsc/'

    def fetch
      go_to_kindle_management_page
      begin
        load_next_kindle_list
      rescue => e
        puts "[ERROR] #{e}"
        puts e.backtrace
        puts
        puts "Retry manually -> client.adapter.load_next_kindle_list or client.session etc."
      end
    end

    def go_to_kindle_management_page
      log "Visiting kindle management page"
      3.times do
        session.visit URL_FOR_KINDLE_CONTENTS
        wait_for_selector('.navHeader_title_myx')
        if session.has_css?('.navHeader_title_myx')
          log "Page found '#{session.first('.navHeader_title_myx').text}'"
          break
        else
          submit_signin_form
        end
      end
    end

    def load_next_kindle_list
      wait_for_selector('.contentCount_myx')
      current_loop = 0
      last_page_scroll_offset = page_scroll_offset
      while current_loop <= max_scroll_attempts
        break if limit && limit < number_of_fetched_books
        if has_more_button?
          snapshot_page
          current_loop = 0

          log "Clicking 'Show More'"
          session.execute_script "window.scrollBy(0,-800)"
          show_more_button.click
          sleep fetching_interval
        else
          log "Loading books with scrolling #{current_loop+1}"
          session.execute_script "window.scrollBy(0,10000)"
        end
        sleep fetching_interval
        if last_page_scroll_offset == page_scroll_offset
          log "Stopping loading because 'page_scroll_offset' didn't change after a loop"
          break
        else
          debug "last_page_scroll_offset:#{last_page_scroll_offset} new page_scroll_offset:#{page_scroll_offset}"
        end
        last_page_scroll_offset = page_scroll_offset
        current_loop += 1
      end
      log "Stopped loading. You may want to resume with 'client.adapter.load_next_kindle_list'"
      snapshot_page
    end

    def load
      books = []
      store.list_html_files.each do |file|
        parser = KindleManager::BooksParser.new(file)
        books += parser.parse
      end
      books.sort_by{|b| [-b.date.to_time.to_i, -b.fetched_at.to_i] }.uniq(&:asin)
    end

    def page_scroll_offset
      session.evaluate_script('window.pageYOffset')
    end

    def has_more_button?
      !!show_more_button
    end

    def show_more_button
      session.all('.contentTableShowMore_myx').find{|e| e['outerHTML'].match(/cnt_shw_more/) }
    end

    def number_of_fetched_books
      re = (AmazonInfo.domain =~ /\.jp\z/ ? /(\d+)〜(\d+)/ : /(\d+) - (\d+)/)
      wait_for_selector('.contentCount_myx')
      text = doc.css('.contentCount_myx').text
      m = text.match(re)
      return m[2].to_i if m.present?
      raise("Couldn't get the number of fetched books [#{text}]")
    end

    def loading?
      session.first('.myx-popover-loading-wrapper').present?
    end

    def snapshot_page
      if (text = doc.css('.contentCount_myx').try!(:text)).present?
        log "Current page [#{text.to_s.gsub(/[[:space:]]+/, ' ').strip}]"
      end
      store.record_page
      log "Saving page"
    end

    def fetching_interval
      @options.fetch(:fetching_interval, 3)
    end
  end
end
