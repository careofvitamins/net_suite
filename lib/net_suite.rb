# frozen_string_literal: true

require 'attr_extras'
require 'active_support'
require 'active_support/core_ext'

module NetSuite
  extend ActiveSupport::Autoload

  autoload :AuthToken
  autoload :Client
  autoload :Config
  autoload :VERSION

  class Error < StandardError; end
end
