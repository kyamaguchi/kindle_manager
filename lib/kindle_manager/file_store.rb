module KindleManager
  class FileStore

    def initialize(session, options = {})
      @time = Time.current
      @session = session
    end

    def base_dir
      File.join('downloads', @time.strftime("%Y%m%d%H%M%S"))
    end

    def html_path(time)
      build_filepath(time, 'html')
    end

    def image_path(time)
      build_filepath(time, 'png')
    end

    def record_page
      time = Time.current
      @session.save_page(html_path(time))
      @session.save_screenshot(image_path(time))
    end

    private

      def build_filepath(time, ext)
        File.join(base_dir, "#{time.strftime('%Y%m%d%H%M%S')}#{(time.usec / 1000.0).round}.#{ext}")
      end
  end
end
