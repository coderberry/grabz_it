module GrabzIt
  class Client
    attr_accessor :app_key, :app_secret, :url, :callback_url, :browser_width, :browser_height, 
                  :output_width, :output_height, :custom_id, :format, :delay

    API_BASE_URL = "http://grabz.it/services/"

    ##
    # Initialize the +GrabzIt::Client+ class
    #
    # @param [String] app_key Application Key provided by grabz.it
    # @param [String] app_secret Application Secret provided by grabz.it
    #
    # @raise [ArgumentError] Exception raised if the app_key or app_secret is not provided
    #
    def initialize(app_key, app_secret)
      @app_key = app_key
      @app_secret = app_secret
      raise(ArgumentError, "You must provide app_key and app_secret") unless @app_key && @app_secret
    end

    ##
    # Calls the GrabzIt web service to take the screenshot and saves it to the target path provided. Warning, this is a 
    # SYNCHONOUS method and can take up to 5 minutes before a response.
    #
    # @param [String] target_path File path that the file should be saved to (including file name and extension)
    # @param [Hash] options Data that is to be passed to the web service
    # @option options [String]  :url The URL that the screenshot should be made of
    # @option options [String]  :callback_url The handler the GrabzIt web service should call after it has completed its work
    # @option options [String]  :custom_id A custom identifier that you can pass through to the screenshot webservice. This will be returned with the callback URL you have specified.
    # @option options [Integer] :browser_width The width of the browser in pixels
    # @option options [Integer] :browser_height The height of the browser in pixels
    # @option options [Integer] :output_width The width of the resulting thumbnail in pixels
    # @option options [Integer] :output_height The height of the resulting thumbnail in pixels
    # @option options [String]  :format The format the screenshot should be in: bmp8, bmp16, bmp24, bmp, gif, jpg, png
    # @option options [Integer] :delay The number of milliseconds to wait before taking the screenshot
    # 
    # @return [GrabzIt::Response] The parsed response.
    #
    # @example
    #   client = GrabzIt::Client.new('TEST_KEY', 'TEST_SECRET')
    #   options = {
    #     :url            => 'http://grabz.it',
    #     :callback_url   => 'http://example.com/callback',
    #     :browser_width  => 1024,
    #     :browser_height => 768,
    #     :output_width   => 800,
    #     :output_height  => 600,
    #     :custom_id      => '12345',
    #     :format         => 'png',
    #     :delay          => 1000
    #   }
    #   response = client.save_picture('google', options)
    #
    def save_picture(target_path, options = {})
      response = take_picture(options)

      # Wait for the response to be ready
      iterations = 0
      while true do
        status = get_status(response.screenshot_id)

        if status.failed?
          raise "The screenshot did not complete with errors: " + status.message

        elsif status.available?
          image = get_picture(response.screenshot_id)
          image.save(target_path)
          break
        end

        # Check again in 1 second with a max of 5 minutes
        if iterations <= (5 * 60)
          sleep(1)
        else
          raise Timeout::Error
        end
      end

      true
    end

    ##
    # Calls the GrabzIt web service to take the screenshot.
    #
    # @param [Hash] options Data that is to be passed to the web service
    # @option options [String]  :url The URL that the screenshot should be made of
    # @option options [String]  :callback_url The handler the GrabzIt web service should call after it has completed its work
    # @option options [String]  :custom_id A custom identifier that you can pass through to the screenshot webservice. This will be returned with the callback URL you have specified.
    # @option options [Integer] :browser_width The width of the browser in pixels
    # @option options [Integer] :browser_height The height of the browser in pixels
    # @option options [Integer] :output_width The width of the resulting thumbnail in pixels
    # @option options [Integer] :output_height The height of the resulting thumbnail in pixels
    # @option options [String]  :format The format the screenshot should be in: bmp8, bmp16, bmp24, bmp, gif, jpg, png
    # @option options [Integer] :delay The number of milliseconds to wait before taking the screenshot
    # 
    # @return [GrabzIt::Response] The parsed response.
    #
    # @example
    #   client = GrabzIt::Client.new('TEST_KEY', 'TEST_SECRET')
    #   options = {
    #     :url            => 'http://grabz.it',
    #     :callback_url   => 'http://example.com/callback',
    #     :browser_width  => 1024,
    #     :browser_height => 768,
    #     :output_width   => 800,
    #     :output_height  => 600,
    #     :custom_id      => '12345',
    #     :format         => 'png',
    #     :delay          => 1000
    #   }
    #   response = client.take_picture(options)
    #
    def take_picture(options = {})
      parse_options(options)
      action = "takepicture.ashx"
      res = query_api(action, generate_params)
      response = Response.new(res.body)
      raise response.message if response.message
      response
    end

    ##
    # Get the current status of a GrabzIt screenshot.
    #
    # @param [String] screenshot_id The id of the screenshot provided by the GrabzIt api
    # 
    # @return [GrabzIt::Status] The parsed status.
    #
    # @example
    #   client = GrabzIt::Client.new('TEST_KEY', 'TEST_SECRET')
    #   status = client.get_status('Y2F2bmViQGdtYWlsLmNvbQ==-20943258e37c4fc28c4977cd76c40f58')
    #
    def get_status(screenshot_id)
      action = "getstatus.ashx"
      response_body = query_api(action, { :id => screenshot_id })
      status = Status.new(response_body)
      raise status.message if status.message
      status
    end

    ##
    # Get all the cookies that GrabzIt is using for a particular domain. This may include your user set cookies as well.
    #
    # @param [String] domain The domain of the cookie
    # 
    # @return [GrabzIt::CookieJar] The container that holds the cookies
    #
    # @example
    #   client = GrabzIt::Client.new('TEST_KEY', 'TEST_SECRET')
    #   cookie_jar = client.get_cookie_jar('google')
    #
    def get_cookie_jar(domain)
      action = "getcookies.ashx"
      sig = Digest::MD5.hexdigest(@app_secret + "|" + domain)
      params = {
        :key => URI.escape(@app_key),
        :domain => URI.escape(domain),
        :sig => sig
      }
      res = query_api(action, params)
      cookie_jar = CookieJar.new(res.body)
      raise cookie_jar.message if cookie_jar.message
      cookie_jar
    end

    ##
    # Pending API documentation
    #
    # def set_cookie(options = {})
    # end

    ##
    # Pending API documentation
    #
    # def delete_cookie(name, domain)
    # end

    ##
    # Get the screenshot image
    #
    # @param [String] screenshot_id The id of the screenshot provided by the GrabzIt api
    # 
    # @return [GrabzIt::Image] The image object
    #
    # @example
    #   client = GrabzIt::Client.new('TEST_KEY', 'TEST_SECRET')
    #   image = client.get_image('Y2F2bmViQGdtYWlsLmNvbQ==-20943258e37c4fc28c4977cd76c40f58')
    #   puts image.content_type
    #   => 'image/png'
    #   puts image.size
    #   => 129347
    #   image.save("/tmp/myimage.png")
    #   File.exist?("/tmp/myimage.png")
    #   => true
    #
    def get_picture(screenshot_id)
      action = "getpicture.ashx"
      res = query_api(action, { :id => screenshot_id })
      image = Image.new(res)
      image
    end

  private

    # Helper method that performs the request
    def query_api(action, params)
      params = params.symbolize_keys
      uri = URI("#{API_BASE_URL}#{action}")
      uri.query = URI.encode_www_form(params)
      res = Net::HTTP.get_response(uri)
      res
    end

    # Convert the options into the instance variable values
    def parse_options(options={})
      options = options.symbolize_keys
      @url            = options[:url] || ''
      @callback_url   = options[:callback_url]   || ''
      @browser_width  = options[:browser_width]  || ''
      @browser_height = options[:browser_height] || ''
      @output_width   = options[:output_width]   || ''
      @output_height  = options[:output_height]  || ''
      @custom_id      = options[:custom_id]      || ''
      @format         = options[:format]         || ''
      @delay          = options[:delay]          || ''
    end

    # Generate the params that are to be used in the request
    def generate_params
      {
        :key      => URI.escape(@app_key),
        :url      => URI.escape(@url),
        :width    => @output_width,
        :height   => @output_height,
        :format   => @format,
        :bwidth   => @browser_width,
        :bheight  => @browser_height,
        :callback => URI.escape(@callback_url),
        :customid => URI.escape(@custom_id),
        :delay    => @delay,
        :sig      => generate_signature
      }
    end

    # Generate the signature that is used in the request
    def generate_signature
      sig = []
      sig << @app_secret
      sig << @url
      sig << @callback_url
      sig << @format
      sig << @output_height
      sig << @output_width
      sig << @browser_height
      sig << @browser_width
      sig << @custom_id
      sig << @delay

      Digest::MD5.hexdigest(sig.join('|'))
    end

  end
end
