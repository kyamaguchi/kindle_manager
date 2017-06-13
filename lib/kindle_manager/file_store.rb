module KindleManager
  class FileStore
    attr_accessor :dir_name, :session

    def initialize(options = {})
      @dir_name = options.fetch(:dir_name) do
        tmp_dir_name = options[:create] ? nil : find_latest_dir_name
        tmp_dir_name.presence || Time.current.strftime("%Y%m%d%H%M%S")
      end
      @sub_dir = options.fetch(:sub_dir, nil)
      @session = options.fetch(:session, nil)
    end

    def base_dir
      File.join([self.class.downloads_dir, @sub_dir, @dir_name].compact)
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
      self.class.list_html_files(@dir_name)
    end

    def find_latest_dir_name
      self.class.list_download_dirs.sort.last.to_s.split('/').last
    end

    private

      def build_filepath(time, ext)
        File.join(base_dir, "#{time.strftime('%Y%m%d%H%M%S')}#{(time.usec / 1000.0).round.to_s.rjust(3,'0')}.#{ext}")
      end
  end
end
