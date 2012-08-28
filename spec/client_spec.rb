require "spec_helper"

describe GrabzIt::Client do

  it "should raise an error when instanciating without the api_key or api_secret" do
    lambda { GrabzIt::Client.new }.should raise_error(ArgumentError)
  end

  describe "with a valid api_key and api_secret" do
    before(:each) do
      @client = GrabzIt::Client.new('TEST_KEY', 'TEST_SECRET')
      @options = {
        :url            => 'http://grabz.it',
        :callback_url   => 'http://example.com/callback',
        :browser_width  => 1024,
        :browser_height => 768,
        :output_width   => 800,
        :output_height  => 600,
        :custom_id      => '12345',
        :format         => 'png',
        :delay          => 1000
      }
    end

    it "#take_picture" do
      res = @client.take_picture(@options)
      puts res.inspect
    end

    it "#parse_options" do
      @client.send(:parse_options, @options)
      @options.each do |k, val|
        @client.send(k).should eq(val)
      end
    end

    it "#generate_params" do
      @client.send(:parse_options, @options)
      query_string = @client.send(:generate_params)
      # query_string.should eq('key=TEST_KEY&url=http://grabz.it&width=800&height=600&format=png&bwidth=1024&bheight=768&callback=http://example.com/callback&customid=12345&delay=1000&sig=6419e21afbf4d178894bce8dafa91c6d')
    end

    it "#generate_signature" do
      @client.send(:parse_options, @options)
      signature = @client.send(:generate_signature)
      signature.should eq('6419e21afbf4d178894bce8dafa91c6d')
    end

  end

end
