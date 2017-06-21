module KindleManager
  class HighlightsAdapter < BaseAdapter
    KINDLE_HIGHLIGHT_URL = "https://read.#{AmazonInfo.domain}/kp/notebook"

    def fetch
      go_to_kindle_highlights_page
      fetch_library_ids
      fetch_kindle_highlights
    end

    def go_to_kindle_highlights_page
      log "Visiting kindle highlights page"
      session.visit KINDLE_HIGHLIGHT_URL
      wait_for_selector('#library')
      check_library_scroll
      snapshot_page
    end

    def fetch_library_ids
      @last_scroll_top = check_library_scroll
      20.times do
        scroll_library_pane(@last_scroll_top + 20000)
        sleep(2)
        new_scroll_top = check_library_scroll
        break if @last_scroll_top == new_scroll_top
        @last_scroll_top = new_scroll_top
      end
      snapshot_page
      @library_ids = doc.css('#library #kp-notebook-library > .a-row').map{|e| e['id'] }
      log "Number of library ids is #{@library_ids.size}"
    end

    def check_library_scroll
      scroll_top = session.evaluate_script("$('#library .kp-notebook-scroller-addon').get(0).scrollTop")
      scroll_height = session.evaluate_script("$('#library .kp-notebook-scroller-addon').get(0).scrollHeight")
      offset_height = session.evaluate_script("$('#library .kp-notebook-scroller-addon').get(0).offsetHeight")
      log "Scroll top:#{scroll_top} height:#{scroll_height} offset_height:#{offset_height}"
      scroll_top
    end

    def scroll_library_pane(target_scroll_top)
      session.evaluate_script("$('#library .kp-notebook-scroller-addon').get(0).scrollTop = #{target_scroll_top}")
    end

    def fetch_kindle_highlights
      @loaded_library_ids ||= []
      @library_ids.each do |library_id|
        next if @loaded_library_ids.include?(library_id)
        log "Loading highlights for #{library_id}"
        session.first("##{library_id}").click
        wait_for_selector('#annotations .kp-notebook-annotation-container', wait_time: 10)
        @title = doc.css('#annotations .kp-notebook-annotation-container h3.kp-notebook-metadata').try!(:text)
        10.times do
          sleep(1)
          @highlights_count = doc.css('#annotations .kp-notebook-annotation-container #kp-notebook-highlights-count').try!(:text)
          @notes_count = doc.css('#annotations .kp-notebook-annotation-container #kp-notebook-notes-count').try!(:text)
          break if @highlights_count != '--' && @notes_count != '--'
        end
        snapshot_page("Saving page for [#{@title}] (#{library_id}) highlights:#{@highlights_count} notes:#{@notes_count}")
        if @title.present?
          @loaded_library_ids << library_id
        else
          log "[ERROR] Failed to load #{library_id} or this book doesn't have any highlights and notes"
        end
      end
      failed_ids = @library_ids - @loaded_library_ids
      log("May have failed with #{failed_ids.inspect}. Retry with client.adapter.session.first('#B000000000').click") if failed_ids.size > 0
      snapshot_page
    end

    def load
      # TODO
    end

    def snapshot_page(message = nil)
      store.record_page
      log(message.presence || "Saving page")
    end
  end
end