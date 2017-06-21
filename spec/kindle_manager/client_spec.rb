require 'spec_helper'

describe KindleManager::Client do
  describe '#load_kindle_books', require_fixture: true do
    # Copy a directory in 'downloads/books/' to 'spec/fixtures/downloads/books/'
    it "lists books" do
      client = KindleManager::Client.new
      books = client.load_kindle_books
      expect(books.first.asin).to be_present
      expect(books.size).to be > 0
      expect(books.map(&:asin).uniq.size).to eql(books.uniq.size)
    end
  end

  describe '#load_kindle_highlights', require_fixture: true do
    # Copy a directory in 'downloads/highlights/' to 'spec/fixtures/downloads/highlights/'
    it "lists highlights" do
      client = KindleManager::Client.new
      books = client.load_kindle_highlights
      expect(books.first.asin).to be_present
      expect(books.size).to be > 0
      expect(books.map(&:asin).uniq.size).to eql(books.uniq.size)
      expect(books.none?(&:invalid?)).to be_truthy
    end
  end
end
