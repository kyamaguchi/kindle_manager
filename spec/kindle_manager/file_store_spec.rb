require 'spec_helper'

describe KindleManager::FileStore do
  let(:session) do
    session = Capybara::Session.new(:selenium)
    session.visit('http://www.google.com')
    session
  end

  describe '#base_dir' do
    it "includes directory with timestamp" do
      store = KindleManager::FileStore.new(nil)
      expect(store.base_dir).to match(%r{\Adownloads/#{Time.current.strftime('%Y%m%d')}\d{6}})
    end
  end

  describe '#html_path' do
    it "has filename with given time" do
      store = KindleManager::FileStore.new(nil)
      time = Time.current
      expect(store.html_path(time)).to match(%r{\Adownloads/\d{14}/\d{17}\.html\z})
    end
  end

  describe '#image_path' do
    it "has filename with given time" do
      store = KindleManager::FileStore.new(nil)
      time = Time.current
      expect(store.image_path(time)).to match(%r{\Adownloads/\d{14}/\d{17}\.png\z})
    end
  end

  describe '#record_page' do
    it "saves files in downloads directory" do
      store = KindleManager::FileStore.new(session)
      store.record_page
      expect(Dir[File.join(store.base_dir,'*')].select { |f| File.file? f }.size).to be > 0
    end

    it "saves multiple pages" do
      store = KindleManager::FileStore.new(session)
      store.record_page
      session.fill_in 'lst-ib', with: 'Capybara'
      session.click_on 'Google 検索'
      expect(session).to have_selector('#resultStats')
      store.record_page
      expect(Dir[File.join(store.base_dir,'*.html')].select { |f| File.file? f }.map{|f| File.read(f).size }.uniq.size).to be >= 2
    end
  end
end
