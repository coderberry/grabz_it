require 'rexml/document'
require 'digest/md5'
require 'uri'
require 'net/http'

Dir[File.join(File.dirname(__FILE__), "grabz_it", "*rb")].each do |file|
  require file
end
