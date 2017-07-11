module KindleManager
  class BaseAdapter
    include AmazonAuth::CommonExtension

    attr_accessor :store, :session, :options

    def initialize(options)
      @options = options
      @session = options.fetch(:session, nil)
      extend(AmazonAuth::SessionExtension)

      @store = KindleManager::FileStore.new(options.merge(session: @session))
      log "Directory for downloaded pages is #{store.target_dir}"
    end

    def limit
      options.fetch(:limit, nil)
    end

    def max_scroll_attempts
      options.fetch(:max_scroll_attempts, 20)
    end
  end
end
