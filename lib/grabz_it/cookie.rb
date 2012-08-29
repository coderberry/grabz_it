module GrabzIt
  class Cookie
    attr_accessor :name, :value, :domain, :path, :http_only, :expires, :type

    # def initialize(options = {})
    #   options = options.symbolize_keys
    #   @domain    = options[:domain]
    #   @name      = options[:name]
    #   @value     = options[:value]
    #   @path      = options[:path]
    #   @http_only = options[:http_only]
    #   @expires   = options[:expires]
    # end

    # def params_for_set_request
    #   {
    #     :domain    => URI.escape(@domain)  || '',
    #     :name      => URI.escape(@name)    || '',
    #     :value     => URI.escape(@value)   || '',
    #     :path      => URI.escape(@path)    || '',
    #     :http_only => @http_only ? 1 : 0, 
    #     :expires   => URI.escape(@expires) || ''
    #   }
    # end

    # def generate_signature(app_key)
    #   parts = []
    #   parts << app_key
    #   parts << @name
    #   parts << @domain
    #   parts << @value
    #   parts << @path
    #   parts << @http_only ? 1 : 0
    #   parts << @expires
    #   parts << 0
    #   unencoded_sig = parts.join('|')
    #   puts "SIG: #{unencoded_sig}"
    #   sig = Digest::MD5.hexdigest(unencoded_sig)
    # end
  end
end
