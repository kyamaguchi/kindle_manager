require 'spec_helper'

describe KindleManager::BooksParser do
  def find_fixture_filepath(name)
    path = File.join('spec', 'fixtures', 'files', name)
    pending("Put your html in #{path} for testing") unless File.exists?(path)
    path
  end

  before do
    filepath = find_fixture_filepath('test.html')
    @parser = KindleManager::BooksParser.new(filepath)
  end

  it "finds selector of list table" do
    expect(@parser.body).to be_present
    expect(@parser.doc.css("div[id^='contentTabList_']").size).to be > 0
  end

  it "finds list table" do
    expect(@parser.parse.size).to be > 0
    expect(@parser.parse.first).to be_a(KindleManager::BooksParser::BookRow)
  end

  context 'BookRow' do
    it "has information" do
      book_row = @parser.parse.last
      expect(book_row.asin).to match(/\AB0.{8}\z/)
      expect(book_row.title).to be_present
      expect(@parser.parse.map(&:tag)).to include('Sample')
      expect(book_row.author).to be_present
      expect(book_row.date).to be_present
      expect(book_row.date).to be_a(Date)
      expect(@parser.parse.map(&:collection_count).compact).to be_present
    end

    it "prints json" do
      book_row = @parser.parse.last
      json = book_row.to_json
      expect(json).to match(/"asin"/)
      expect(json).to match(/"title"/)
      expect(json).to match(/"\d{4}-\d{2}-\d{2}"/) # date
      expect(@parser.parse.to_json).to match(/\[{"asin":/)
    end
  end
end
