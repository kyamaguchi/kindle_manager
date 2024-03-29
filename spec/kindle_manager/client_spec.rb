require 'spec_helper'

describe KindleManager::Client do
  describe '#load_kindle_books' do
    before do
      pending("Put your files in 'tmp/books/' into 'spec/fixtures/tmp/books/' for testing") if Dir.glob("spec/fixtures/tmp/books/*/*.html").blank?
    end

    it "lists books" do
      client = KindleManager::Client.new
      books = client.load_kindle_books
      # puts books.map(&:inspect)
      expect(books.size).to be > 0
      expect(books.first.asin).to be_present
      expect(books.map(&:asin).uniq.size).to eql(books.uniq.size)
      expect{
        books.map(&:to_hash)
      }.not_to raise_error
    end
  end

  describe '#load_kindle_highlights' do
    before do
      pending("Put your files in 'tmp/highlights/' into 'spec/fixtures/tmp/highlights/' for testing") if Dir.glob("spec/fixtures/tmp/highlights/*/*.html").blank?
    end

    it "lists highlights" do
      client = KindleManager::Client.new
      books = client.load_kindle_highlights
      expect(books.size).to be > 0
      expect(books.first.asin).to be_present
      expect(books.map(&:asin).uniq.size).to eql(books.uniq.size)
      expect(books.none?(&:invalid?)).to be_truthy
      expect{
        books.map(&:to_hash)
      }.not_to raise_error
    end
  end
end
