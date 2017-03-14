require 'spec_helper'

describe KindleManager::FileStore do
  before do
    allow(KindleManager::FileStore).to receive(:downloads_dir).and_return('spec/fixtures/downloads')
  end

  let(:session) do
    session = Capybara::Session.new(:selenium)
    session.visit('http://www.google.com')
    session
  end

  describe '#base_dir' do
    it "includes directory with timestamp" do
      store = KindleManager::FileStore.new(nil)
      expect(store.base_dir).to match(%r{downloads/#{Time.current.strftime('%Y%m%d')}\d{6}})
    end
  end

  describe '#dir_name' do
    it "creates dir name from timestamp" do
      store = KindleManager::FileStore.new(nil)
      expect(store.dir_name).to match(%r{#{Time.current.strftime('%Y%m%d')}\d{6}})
    end

    it "accepts argument of dir_name" do
      store = KindleManager::FileStore.new(nil, dir_name: '20170313223118')
      expect(store.dir_name).to eql('20170313223118')
    end

    it "finds latest dir_name when latest flag is given" do
      store = KindleManager::FileStore.new(nil, latest: true)
      expect(store.dir_name).to eql('20170313223421')
    end
  end


  describe '#html_path' do
    it "has filename with given time" do
      store = KindleManager::FileStore.new(nil)
      time = Time.current
      expect(store.html_path(time)).to match(%r{downloads/\d{14}/\d{17}\.html\z})
    end
  end

  describe '#image_path' do
    it "has filename with given time" do
      store = KindleManager::FileStore.new(nil)
      time = Time.current
      expect(store.image_path(time)).to match(%r{downloads/\d{14}/\d{17}\.png\z})
    end
  end

  describe '#record_page', browser: true do
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

  describe '.list_download_dirs' do
    it 'lists dirs' do
      expect(KindleManager::FileStore.list_download_dirs.size).to be > 0
    end
  end

  describe '.list_html_files' do
    it 'lists files' do
      expect(KindleManager::FileStore.list_html_files.size).to be > 0
    end

    it 'lists files with args' do
      expect(KindleManager::FileStore.list_html_files('20170313223118').size).to be > 0
    end
  end
end
