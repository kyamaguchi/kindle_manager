require 'spec_helper'

describe KindleManager::Client do
  describe '.new' do
    it "setup store with default options" do
      client = KindleManager::Client.new
      expect(client.store.dir_name).to be_present
    end

    it "creates new download dir with create option" do
      client = KindleManager::Client.new(create: true)
      expect(client.store.dir_name).to match(/\A#{Time.now.strftime('%Y%m%d')}/)
    end
  end

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
