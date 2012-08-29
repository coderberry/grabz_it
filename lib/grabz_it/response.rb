module GrabzIt
  class Response
    attr_accessor :result, :screenshot_id, :message
    
    def initialize(xml)
      doc = REXML::Document.new(xml)
      @result = doc.root.elements['Result'].text
      @screenshot_id = doc.root.elements['ID'].text
      @message = doc.root.elements['Message'].text
    end

    def successful?
      @result == 'True'
    end

  end
end
