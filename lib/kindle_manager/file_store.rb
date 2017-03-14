module KindleManager
  class FileStore

    def initialize(session, options = {})
      @dir_name = Time.current.strftime("%Y%m%d%H%M%S")
      @session = session
    end

    def base_dir
      File.join(self.class.downloads_dir, @dir_name)
    end

    def self.downloads_dir
      'downloads'
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

    def self.list_download_dirs
      Dir["#{downloads_dir}/*"].select{|f| File.directory? f }
    end

    def self.list_html_files(dir = nil)
      if dir
        Dir[File.join(downloads_dir, dir,'*.html')].select{|f| File.file? f }
      else
        Dir["#{downloads_dir}/*/*.html"].select{|f| File.file? f }
      end
    end

    def list_html_files
      self.class.list_html_files(base_dir)
    end

    private

      def build_filepath(time, ext)
        File.join(base_dir, "#{time.strftime('%Y%m%d%H%M%S')}#{(time.usec / 1000.0).round}.#{ext}")
      end
  end
end
