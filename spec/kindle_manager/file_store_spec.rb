require 'spec_helper'

describe KindleManager::FileStore do
  let(:session) do
    session = Capybara::Session.new(:selenium)
    session.visit('http://www.google.com')
    session
  end

  before do
    allow(Capybara).to receive(:save_path).and_return('spec/fixtures/store_test/downloads')
  end

  describe '#target_dir' do
    it "includes directory with timestamp" do
      store = KindleManager::FileStore.new
      expect(store.target_dir).to match(%r{books/\d{14}})
    end

    it "accepts sub_dir option" do
      store = KindleManager::FileStore.new(sub_dir: 'highlights')
      expect(store.target_dir).to match(%r{highlights/\d{14}})
    end
  end

  describe '#dir_name' do
    let(:old_dir_name) { '20170313223118' }
    let(:new_dir_name) { '20170313223421' }

    it "creates dir name from timestamp create flag is given" do
      store = KindleManager::FileStore.new(create: true)
      expect(store.dir_name).to match(%r{#{Time.current.strftime('%Y%m%d')}\d{6}})
      expect(store.dir_name).to_not eql(old_dir_name)
      expect(store.dir_name).to_not eql(new_dir_name)
    end

    it "accepts argument of dir_name" do
      store = KindleManager::FileStore.new(dir_name: old_dir_name)
      expect(store.dir_name).to eql(old_dir_name)
    end

    it "finds latest dir_name by default" do
      store = KindleManager::FileStore.new
      expect(store.dir_name).to eql(new_dir_name)
      expect(store.list_html_files.size).to be > 0
    end

    it "creates directory when directories don't exist" do
      allow(Capybara).to receive(:save_path).and_return('spec/fixtures/empty')
      store = KindleManager::FileStore.new
      expect(store.dir_name).to match(%r{#{Time.current.strftime('%Y%m%d')}\d{6}})
      expect(store.dir_name).to_not eql(old_dir_name)
      expect(store.dir_name).to_not eql(new_dir_name)
    end
  end


  describe '#html_path' do
    it "has filename with given time" do
      store = KindleManager::FileStore.new
      time = Time.current
      expect(store.html_path(time)).to match(%r{books/\d{14}/\d{17}\.html\z})
    end
  end

  describe '#image_path' do
    it "has filename with given time" do
      store = KindleManager::FileStore.new
      time = Time.current
      expect(store.image_path(time)).to match(%r{books/\d{14}/\d{17}\.png\z})
    end
  end

  describe '#list_html_files' do
    it "lists html files" do
      store = KindleManager::FileStore.new
      expect(store.list_html_files.size).to be > 0
      expect(store.list_html_files.first).to match(%r{books/\d{14}/\d{17}\.html\z})
    end

    it "lists html files with sub_dir option" do
      store = KindleManager::FileStore.new(sub_dir: 'highlights')
      expect(store.list_html_files.size).to be > 0
      expect(store.list_html_files.first).to match(%r{highlights/\d{14}/\d{17}\.html\z})
    end
  end

  describe '#record_page', browser: true do
    it "saves files in downloads directory" do
      store = KindleManager::FileStore.new(session: session)
      store.record_page
      expect(Dir[File.join(store.target_dir,'*')].select { |f| File.file? f }.size).to be > 0
    end

    it "saves multiple pages" do
      store = KindleManager::FileStore.new
      store.session = session
      store.record_page
      session.fill_in 'lst-ib', with: 'Capybara'
      session.click_on 'Google 検索'
      expect(session).to have_selector('#resultStats')
      store.record_page
      expect(Dir[File.join(store.target_dir,'*.html')].select { |f| File.file? f }.map{|f| File.read(f).size }.uniq.size).to be >= 2
    end
  end
end
