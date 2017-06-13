module KindleManager
  class HighlightsAdapter
    KINDLE_HIGHLIGHT_URL = 'https://read.amazon.co.jp/kp/notebook'

    def store_for_highlights
      @_store_for_highlights ||= KindleManager::FileStore.new(@options.merge(sub_dir: 'highlights'))
    end

    def setup_file_store_for_highlights
      store_for_highlights.session = session
      log "Directory for downloaded highlights pages is #{store.base_dir}"
    end

    def fetch_kindle_highlights
      sign_in
      setup_file_store_for_highlights
      session.visit KINDLE_HIGHLIGHT_URL

      store_for_highlights.record_page
      log "Saving highlights page"
    end
  end
end
