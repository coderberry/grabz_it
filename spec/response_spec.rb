require "spec_helper"

describe GrabzIt::Response do

  it "#initialize with successful response" do
    xml = <<-EOF
<?xml version="1.0"?>
<WebResult xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <Result>True</Result>
  <ID>Y2F2bmViQGdtYWlsLmNvbQ==-20943258e37c4fc28c4977cd76c40f58</ID>
  <Message />
</WebResult>
    EOF

    api_response = GrabzIt::Response.new(xml)
    api_response.result.should eq('True')
    api_response.screenshot_id.should eq('Y2F2bmViQGdtYWlsLmNvbQ==-20943258e37c4fc28c4977cd76c40f58')
    api_response.message.should be_nil
    api_response.successful?.should be_true
  end

  it "#initialize with invalid api key" do
    xml = <<-EOF
<?xml version="1.0"?>
<WebResult xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <Result>False</Result>
  <ID />
  <Message>Application Key not recognised.</Message>
</WebResult>
    EOF

    api_response = GrabzIt::Response.new(xml)
    api_response.result.should eq('False')
    api_response.screenshot_id.should be_nil
    api_response.message.should eq('Application Key not recognised.')
    api_response.successful?.should be_false
  end

end
