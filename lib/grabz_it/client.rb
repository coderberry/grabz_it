require 'digest/md5'
require 'uri'
require 'net/http'

module GrabzIt
  class Client
    attr_accessor :app_key, :app_secret, :url, :callback_url, :browser_width, :browser_height, 
                  :output_width, :output_height, :custom_id, :format, :delay

    API_BASE_URL = "http://grabz.it/services/"

    def initialize(app_key, app_secret)
      @app_key = app_key
      @app_secret = app_secret
      raise(ArgumentError, "You must provide app_key and app_secret") unless @app_key && @app_secret
    end

    def take_picture(options={})
      parse_options(options)
      uri = URI("#{API_BASE_URL}takepicture.ashx")
      uri.query = URI.encode_www_form(generate_params)
      res = Net::HTTP.get_response(uri)
      puts res.body if res.is_a?(Net::HTTPSuccess)
      res
    end

  private

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
