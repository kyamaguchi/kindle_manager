module KindleManager
  class FileStore
    attr_accessor :dir_name, :session

    def initialize(options = {})
      @sub_dir = options.fetch(:sub_dir, 'books').to_s
      @dir_name = options.fetch(:dir_name) do
        tmp_dir_name = options[:create] ? nil : find_latest_dir_name
        tmp_dir_name.presence || Time.current.strftime("%Y%m%d%H%M%S")
      end
      @session = options.fetch(:session, nil)
    end

    def downloads_dir
      'downloads'
    end

    def root_dir
      File.join(downloads_dir, @sub_dir)
    end

    def base_dir
      File.join(root_dir, @dir_name)
    end

    def list_work_dirs
      Dir["#{root_dir}/*"].select{|f| File.directory? f }
    end

    def find_latest_dir_name
      list_work_dirs.sort.last.to_s.split('/').last
    end

    def list_html_files(dir = nil)
      Dir[File.join(base_dir,'*.html')].select{|f| File.file? f }
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
        File.join(base_dir, "#{time.strftime('%Y%m%d%H%M%S')}#{(time.usec / 1000.0).round.to_s.rjust(3,'0')}.#{ext}")
      end
  end
end
