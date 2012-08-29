module GrabzIt
  class CookieJar
    attr_accessor :cookies, :message

    def initialize(xml)
      @cookies = []
      doc = REXML::Document.new(xml)
      @message = doc.root.elements['Message'].text
      begin
        add_cookies(doc.root.elements.to_a("//WebResult/Cookies/Cookie"))
      rescue => ex
        raise "Invalid Response: #{xml}"
      end
    end

  private

    def add_cookies(xml_cookies)
      xml_cookies.each do |c|
        cookie = Cookie.new
        cookie.name      = c.elements['Name'].text
        cookie.value     = c.elements['Value'].text
        cookie.domain    = c.elements['Domain'].text
        cookie.path      = c.elements['Path'].text
        cookie.http_only = (c.elements['HttpOnly'].text == 'True')
        cookie.type      = c.elements["Type"].text
        if c.elements['Expires']
          cookie.expires = c.elements['Expires'].text
        end
        @cookies << cookie
      end
    end

  end
end
