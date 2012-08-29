require "spec_helper"

describe GrabzIt::Image do
  before(:each) do
    raw_image = File.read(File.join(File.dirname(__FILE__), 'test_data', 'test_image.png'))
    @mocked_response = Struct::MockHTTPResponse.new(raw_image, { 'content-type' => 'image/png' })
  end

  it "#initialize with successful response" do
    image = GrabzIt::Image.new(@mocked_response)
    image.content_type.should eq('image/png')
    image.size.should eq(129347)
  end

  it "#initialize with failed response" do
    lambda { image = GrabzIt::Image.new(nil) }.should raise_error(RuntimeError, "Invalid Response")
  end

  it "#save" do
    image = GrabzIt::Image.new(@mocked_response)
    target = "/tmp/grabz_it_text_image.png"
    saved_image = image.save(target)
    File.exist?(target).should be_true
    File.delete(target) if File.exist?(target) # cleanup
  end

end
