require 'spec_helper'

describe KindleManager::HighlightsParser do
  before do
    filepath = find_fixture_filepath('test_highlights.html')
    @parser = KindleManager::HighlightsParser.new(filepath)
  end

  it "finds one book with notes" do
    expect(@parser.parse.size).to eql(1)
    expect(@parser.parse.first).to be_a(KindleManager::HighlightsParser::BookWithNote)
  end

  context 'BookWithNote' do
    it "has information" do
      book = @parser.parse.last
      expect(book.asin).to match(/\AB0.{8}\z/)
      expect(book.title).to match(/Design Patterns/)
      expect(book.author).to match(/Russ Olsen/)
      expect(book.last_annotated_on).to be_present
      expect(book.last_annotated_on).to be_a(Date)

      expect(book.highlights_count).to eql(book.count_summary['highlights_count'])
      expect(book.notes_count).to eql(book.count_summary['notes_count'])
      expect(book.highlights_and_notes.size).to be > 0
      expect(book.highlights_and_notes.first.keys).to include('location', 'highlight', 'color', 'note')

      expect(book.highlights.size).to eql(book.highlights_count)
      expect(book.highlights.first['highlight']).to match(/Design Patterns/)
      expect(book.notes.size).to eql(book.notes_count)
    end

    it "has timestamp which comes from file" do
      expect(@parser.fetched_at).to be_present
      book = @parser.parse.last
      expect(book.fetched_at).to be_present
    end

    it "prints json" do
      book = @parser.parse.last
      json = book.to_json
      expect(json).to match(/"asin"/)
      expect(json).to match(/"title"/)
      expect(json).to match(/"\d{4}-\d{2}-\d{2}"/) # last_annotated_on
      expect(@parser.parse.to_json).to match(/\[{"asin":/)
    end

    describe '#invalid?' do
      it "verifies count of nodes and count_summary part" do
        book = @parser.parse.last
        expect(book.count_summary['text']).to match(/\d+.*|.*\d.*/m)
        expect(book.count_summary['highlights_count']).to eql(8)
        expect(book.count_summary['notes_count']).to eql(7)
        expect(book.invalid?).to be_falsey
      end
    end
  end
end
