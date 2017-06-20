module KindleManager
  class BooksParser
    class BookRow
      def initialize(node)
        @node = node
      end

      def inspect
        "#<#{self.class.name}:#{self.object_id} #{self.to_hash}>"
      end

      def asin
        @_asin ||= @node['name'].gsub(/\AcontentTabList_/, '')
      end

      def title
        @_title ||= @node.css("div[id^='title']").text
      end

      def tag
        @_tag ||= @node.css("div[id^='listViewTitleTag']").css('.myx-text-bold').first.text.strip
      end

      def author
        @_author ||= @node.css("div[id^='author']").text
      end

      def date
        @_date ||= begin
          date_text = @node.css("div[id^='date']").text
          begin
            Date.parse(date_text)
          rescue ArgumentError => e
            m = date_text.match(/\A(?<year>\d{4})年(?<month>\d{1,2})月(?<day>\d{1,2})日\z/)
            Date.new(m[:year].to_i, m[:month].to_i, m[:day].to_i)
          end
        end
      end

      def collection_count
        @_collection_count ||= @node.css(".collectionsCount .myx-collection-count").first.text.strip.to_i
      end

      def to_hash
        hash = {}
        %w[asin title tag author date collection_count].each do |f|
          hash[f] = send(f)
        end
        hash
      end
    end

    def initialize(filepath, options = {})
      @filepath = filepath
    end

    def book_list
      @book_list ||= doc.css("div[id^='contentTabList_']").map{|e| BookRow.new(e) }
    end

    def doc
      @doc ||= Nokogiri::HTML(body)
    end

    def body
      @body ||= File.read(@filepath)
    end
  end
end
