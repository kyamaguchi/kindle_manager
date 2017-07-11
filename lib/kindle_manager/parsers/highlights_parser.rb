module KindleManager
  class HighlightsParser < BaseParser
    class BookWithNote
      include KindleManager::Parsers::Common

      def initialize(node, options = {})
        @node = node
        @fetched_at = options[:fetched_at]
      end

      def inspect
        "#<#{self.class.name}:#{self.object_id} #{self.to_hash}>"
      end

      def asin
        @_asin ||= @node.css('#kp-notebook-annotations-asin').first['value']
      end

      def title
        @_title ||= @node.css('h3.kp-notebook-metadata').text
      end

      def author
        @_author ||= @node.css('h1.kp-notebook-metadata').first.text
      end

      def last_annotated_on
        @_last_annotated_on ||= parse_date(@node.css('#kp-notebook-annotated-date').text)
      end

      def highlights_count
        @_highlights_count ||= @node.css('.kp-notebook-highlight').size
      end

      def notes_count
        @_notes_count ||= @node.css('.kp-notebook-note').reject{|e| e['class'] =~ /aok-hidden/ }.size
      end

      def highlights_and_notes
        @_highlights_and_notes ||= begin
          # Excluding the first element which has book info
          @node.css('.a-spacing-base')[1..-1].map do |node|
            location = node.css('#kp-annotation-location').first['value'].to_i
            highlight_node = node.css('.kp-notebook-highlight').first
            highlight = highlight_node && highlight_node.css('#highlight').first.text
            color = highlight_node && highlight_node['class'].split.find{|v| v =~ /kp-notebook-highlight-/ }.split('-').last
            note = node.css('#note').first.text
            {'location' => location, 'highlight' => highlight, 'color' => color, 'note' => note}
          end
        end
      end

      def highlights
        highlights_and_notes.reject{|e| e['highlight'].blank? }
      end

      def notes
        highlights_and_notes.reject{|e| e['note'].blank? }
      end

      # This can be used to verify the count of hightlights and notes
      def count_summary
        @_count_summary ||= begin
          text = @node.css('h1.kp-notebook-metadata').last.text.strip
          a, b = text.split('|').map{|text| m = text.match(/\d+/); m.nil? ? nil : m[0].to_i }
          {'text' => text, 'highlights_count' => a, 'notes_count' => b}
        end
      end

      def to_hash
        hash = {}
        %w[asin title author last_annotated_on highlights_count notes_count highlights_and_notes].each do |f|
          hash[f] = send(f)
        end
        hash
      end

      def invalid?
        !!(asin.blank? || count_summary['text'] =~ /--/)
      end
    end

    def parse
      @_parsed ||= begin
        result = doc.css('.kp-notebook-annotation-container').map{|e| BookWithNote.new(e, fetched_at: fetched_at) }
        puts "[DEBUG] This page(#{@filepath}) has many books. asin -> #{result.map(&:asin).join(',')}" if result.size >= 2
        puts "[DEBUG] Incomplete page(#{@filepath}). asin:#{result.first.asin} #{result.first.title} (#{result.first.count_summary['text'].inspect})" if result.any?(&:invalid?)
        result
      end
    end
  end
end
