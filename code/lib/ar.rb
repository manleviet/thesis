# environment
raise "JRuby required"    unless RUBY_PLATFORM =~ /java/
raise "Ruby 1.9 required" unless RUBY_VERSION  =~ /^1.9/

# load path
$: << File.join(File.dirname(__FILE__), 'ar')

# standard libs
require 'java'
require 'pp'
require 'csv'

# core extensions
require 'ext/array'

# app libs
require 'lucene'
require 'mahout'
require 'exceptions'
require 'log'
require 'scale'
require 'task'
require 'perform'
require 'model'
require 'recommender'
require 'ranker'
require 'rmse_eval'
require 'rank_eval'
require 'aggregate'
require 'adaptive'

# config
module AR
  module Config
    # Main data path
    Data = File.expand_path(File.join(File.dirname(__FILE__), '..', 'data')) 
  end
end

