#!/Users/julian2/.rvm/rubies/ruby-1.8.7-p371/bin/ruby

APP_ROOT   = "#{File.dirname(__FILE__)}/.." unless defined?(APP_ROOT)
$LOAD_PATH << "#{APP_ROOT}/lib"

RUBY_VERSION_REQUIRED = "1.8.7"

require 'PageController'

PageController.new(APP_ROOT).build_page
