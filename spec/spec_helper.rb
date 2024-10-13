# frozen_string_literal: true

require 'rspec'
require 'json'

RSpec.configure do |config|
  config.mock_with :rspec
  config.formatter = :documentation
  config.color = true
end
