require 'rexml/document'

module GrabzIt
  class ApiResponse
    attr_accessor :result, :snapshot_id, :message
    
    def initialize(xml)
      doc = REXML::Document.new(xml)
      @result = doc.root.elements['Result'].text
      @snapshot_id = doc.root.elements['ID'].text
      @message = doc.root.elements['Message'].text
    end

    def successful?
      @result == 'True'
    end

  end
end
