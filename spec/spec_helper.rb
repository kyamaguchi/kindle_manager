require "bundler/setup"
require "kindle_manager"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.filter_run_excluding browser: true, require_fixture: true

  config.before do
    allow(KindleManager::FileStore).to receive(:downloads_dir).and_return('spec/fixtures/downloads')
  end
end
