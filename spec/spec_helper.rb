require "bundler/setup"
require "kindle_manager"

Dir[File.join(File.dirname(__FILE__), "..", "spec", "support", "**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.filter_run_excluding browser: true

  config.before do
    allow(Capybara).to receive(:save_path).and_return('spec/fixtures/tmp')

    # Mock credentials
    %w[AMAZON_USERNAME_CODE AMAZON_PASSWORD_CODE AMAZON_CODE_SALT].each do |key|
      ENV[key] = 'test'
    end
  end
end
