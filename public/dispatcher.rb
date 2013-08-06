#!/Users/julian2/.rvm/rubies/ruby-1.9.3-p392/bin/ruby -d

APP_ROOT   = "#{File.dirname(__FILE__)}/.." unless defined?(APP_ROOT)
$LOAD_PATH << "#{APP_ROOT}/lib"

require 'PageController'

PageController.new(APP_ROOT).build_page
