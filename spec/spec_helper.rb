Dir[File.join(File.dirname(__FILE__), "..", "lib", "*.rb")].each do |file|
  require file
end

# Used to mock a response from the web service
Struct.new "MockHTTPResponse", :body, :header
