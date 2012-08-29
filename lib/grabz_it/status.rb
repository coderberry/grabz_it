module GrabzIt
  class Status
    attr_accessor :processing, :cached, :expired, :message

    def initialize(xml)
      doc = REXML::Document.new(xml)
      @processing = (doc.root.elements['Processing'].text == 'True')
      @cached     = (doc.root.elements['Cached'].text == 'True')
      @expired    = (doc.root.elements['Expired'].text == 'True')
      @message    = doc.root.elements['Message'].text
    end

    def failed?
      !@processing && !@cached
    end

    def available?
      @cached
    end
  end
end
