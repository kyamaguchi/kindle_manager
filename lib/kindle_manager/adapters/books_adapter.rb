module KindleManager
  class BooksAdapter < BaseAdapter
    def url_for_kindle_contents
      "https://www.#{ENV['AMAZON_DOMAIN']}/hz/mycd/digital-console/contentlist/booksAll/dateDsc/"
    end

    def fetch
      go_to_kindle_management_page
      begin
        load_next_kindle_list
      rescue => e
        puts "[ERROR] #{e}"
        puts e.backtrace
        puts
        puts "Investigate the error using 'client.session', 'client.doc' etc."
      end
    end

    def go_to_kindle_management_page
      log "Visiting kindle management page"
      3.times do
        session.visit url_for_kindle_contents
        wait_for_selector('#content-page-title')
        if session.has_css?('#content-page-title')
          log "Page found '#{session.first('#content-page-title').text}'"
          break
        else
          submit_signin_form
        end
      end
    end

    def load_next_kindle_list
      wait_for_selector('#CONTENT_COUNT')
      loop do
        snapshot_page
        break if current_page == max_page
        break if limit && limit <= number_of_fetched_books
        session.first("#page-#{current_page + 1}").click
        sleep fetching_interval
      end
      log "Stopped loading. You may want to continue with 'client.session', 'client.doc' etc."
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

    def current_page
      doc.css('#pagination a.active').first.text.to_i
    end

    def max_page
      @_max_page ||= doc.css('#pagination a').last.text.to_i
    end

    def number_of_fetched_books
      re = (AmazonInfo.domain =~ /\.jp\z/ ? /(\d+)から(\d+)/ : / (\d+) to (\d+) /)
      wait_for_selector('#CONTENT_COUNT')
      text = doc.css('#CONTENT_COUNT').text
      log "Number of books: [#{text}]"
      m = text.match(re)
      return m[2].to_i if m.present?
      raise("Couldn't get the number of fetched books [#{text}]")
    end

    def snapshot_page
      if (text = doc.css('#CONTENT_COUNT').try!(:text)).present?
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
