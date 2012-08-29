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

    ## ------------------------------------------------------------------------------------
    # Take Picture
    ## ------------------------------------------------------------------------------------
    it "#take_picture" do
      pending "unable to test without valid app_key and app_secret"
    end

    ## ------------------------------------------------------------------------------------
    # Take Picture
    ## ------------------------------------------------------------------------------------
    describe "#take_picture" do
      it "with successful response" do
        xml = <<-EOF
          <?xml version="1.0"?>
          <WebResult xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
            <Result>True</Result>
            <ID>Y2F2bmViQGdtYWlsLmNvbQ==-20943258e37c4fc28c4977cd76c40f58</ID>
            <Message />
          </WebResult>
        EOF
        @client.stub!(:query_api).and_return(xml)
        response = @client.take_picture(@options)

        response.screenshot_id.should eq('Y2F2bmViQGdtYWlsLmNvbQ==-20943258e37c4fc28c4977cd76c40f58')
        response.successful?.should be_true
      end

      it "with error response" do
        xml = <<-EOF
          <?xml version="1.0"?>
          <WebResult xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
            <Result>False</Result>
            <ID />
            <Message>Application Key not recognised.</Message>
          </WebResult>
        EOF
        @client.stub!(:query_api).and_return(xml)

        lambda{ @client.take_picture(@options) }.should raise_error(RuntimeError, "Application Key not recognised.")
      end
    end

    ## ------------------------------------------------------------------------------------
    # Get Status
    ## ------------------------------------------------------------------------------------
    describe "#get_status" do
      it "with valid screenshot id" do
        xml = <<-EOF
          <?xml version="1.0"?>
          <WebResult xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
            <Processing>False</Processing>
            <Cached>True</Cached>
            <Expired>False</Expired>
            <Message />
          </WebResult>
        EOF
        @client.stub!(:query_api).and_return(xml)
        status = @client.get_status('abcde12345')
        
        status.processing.should be_false
        status.cached.should be_true
        status.expired.should be_false
        status.message.should be_nil
      end

      it "with invalid screenshot id" do
        xml = <<-EOF
          <?xml version="1.0"?>
          <WebResult xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
            <Processing>False</Processing>
            <Cached>False</Cached>
            <Expired>True</Expired>
            <Message />
          </WebResult>
        EOF
        @client.stub!(:query_api).and_return(xml)
        status = @client.get_status('abcde12345')
        
        status.processing.should be_false
        status.cached.should be_false
        status.expired.should be_true
        status.message.should be_nil
      end
    end

    ## ------------------------------------------------------------------------------------
    # Get Picture
    ## ------------------------------------------------------------------------------------
    describe "#get_picture" do
      before(:each) do
        raw_image = File.read(File.join(File.dirname(__FILE__), 'test_data', 'test_image.png'))
        @mocked_response = Struct::MockHTTPResponse.new(raw_image, { 'content-type' => 'image/png' })
      end

      it "with valid screenshot id" do
        @client.stub!(:query_api).and_return(@mocked_response)
        image = @client.get_picture('YXBAMW9uMS5jb20=-4d164e5166134c31b95cd7b9d23e8ed5')
        image.content_type.should eq('image/png')
        image.size.should eq(129347)
      end
    end

    ## ------------------------------------------------------------------------------------
    # Get Cookies
    ## ------------------------------------------------------------------------------------
    describe "#get_cookie_jar" do
      it "with valid domain" do
        xml = <<-EOF
          <?xml version="1.0"?>
          <WebResult xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
            <Cookies>
              <Cookie>
                <Name>secure</Name>
                <Value />
                <Domain>accounts.google.com</Domain>
                <Path>/</Path>
                <HttpOnly>False</HttpOnly>
                <Type>Global</Type>
              </Cookie>
              <Cookie>
                <Name>PREF</Name>
                <Value>ID=c8a1a3e41c52b4ed:TM=1346246013:LM=1346246013:S=_6o6Tap-5lKkES34</Value>
                <Domain>.google.com</Domain>
                <Path>/</Path>
                <HttpOnly>False</HttpOnly>
                <Expires>Sat, 30 Aug 2014 03:13:33 GMT</Expires>
                <Type>Global</Type>
              </Cookie>
              <Cookie>
                <Name>NID</Name>
                <Value>63=zJWKTpnMjJjEhk_9wEEFWYccDWjY7hGrDUfe7csnveQGvD33jdtwOm5fcDh-eHLLwWMlNfzxrM9hwAeWhUkcFNCAjZitNIsewSHf4LCPbfqgaG8eSIMJ7X07p_Gx-bGz</Value>
                <Domain>.google.com</Domain>
                <Path>/</Path>
                <HttpOnly>True</HttpOnly>
                <Expires>Thu, 28 Feb 2013 14:32:20 GMT</Expires>
                <Type>Global</Type>
              </Cookie>
            </Cookies>
            <Message />
          </WebResult>
        EOF
        @client.stub!(:query_api).and_return(xml)
        cookie_jar = @client.get_cookie_jar('google')
        cookie_jar.cookies.size.should eq(3)
        cookie_jar.cookies[0].name.should eq('secure')
        cookie_jar.cookies[0].domain.should eq('accounts.google.com')
      end

      it "with invalid domain" do
        xml = <<-EOF
          <?xml version="1.0"?>
          <WebResult xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
            <Cookies />
            <Message />
          </WebResult>
        EOF
        @client.stub!(:query_api).and_return(xml)
        cookie_jar = @client.get_cookie_jar('fsoi')
        cookie_jar.cookies.should be_empty
      end
    end

    ## ------------------------------------------------------------------------------------
    # Other
    ## ------------------------------------------------------------------------------------

    it "#parse_options" do
      @client.send(:parse_options, @options)
      @options.each do |k, val|
        @client.send(k).should eq(val)
      end
    end

    it "#generate_params" do
      @client.send(:parse_options, @options)
      params = @client.send(:generate_params)
      
      params[:key].should eq('TEST_KEY')
      params[:url].should eq("http://grabz.it")
      params[:width].should eq(800)
      params[:height].should eq(600)
      params[:format].should eq("png")
      params[:bwidth].should eq(1024)
      params[:bheight].should eq(768)
      params[:callback].should eq("http://example.com/callback")
      params[:customid].should eq("12345")
      params[:delay].should eq(1000)
      params[:sig].should eq("6419e21afbf4d178894bce8dafa91c6d")
    end

    it "#generate_signature" do
      @client.send(:parse_options, @options)
      signature = @client.send(:generate_signature)
      signature.should eq('6419e21afbf4d178894bce8dafa91c6d')
    end

  end

end
