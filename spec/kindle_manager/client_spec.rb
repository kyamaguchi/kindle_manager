require 'spec_helper'

describe KindleManager::Client do
  describe '#load_kindle_books', require_fixture: true do
    it "lists books" do
      client = KindleManager::Client.new
      books = client.load_kindle_books
      expect(books.first.asin).to be_present
      expect(books.size).to be > 0
      expect(books.map(&:asin).uniq.size).to eql(books.uniq.size)
    end
  end
end
