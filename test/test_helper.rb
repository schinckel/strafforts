require 'simplecov'
SimpleCov.start

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def setup_cookie(access_token)
    my_cookies = ActionDispatch::Request.new(Rails.application.env_config).cookie_jar
    my_cookies.signed[:access_token] = access_token
    cookies[:access_token] = my_cookies[:access_token]
  end
end
