require "spec_helper"

describe GrabzIt::ApiResponse do

  it "#initialize with invalid api key" do
    xml = <<-EOF
<?xml version="1.0"?>
<WebResult xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <Result>False</Result>
  <ID />
  <Message>Application Key not recognised.</Message>
</WebResult>
    EOF

    api_response = GrabzIt::ApiResponse.new(xml)
    api_response.result.should eq('False')
    api_response.snapshot_id.should be_nil
    api_response.message.should eq('Application Key not recognised.')
    api_response.successful?.should be_false
  end

end
