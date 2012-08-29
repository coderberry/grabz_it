module GrabzIt
  class Image
    attr_accessor :image_bytes, :content_type, :size

    def initialize(response)
      begin
        @image_bytes = response.body
        @size = @image_bytes ? @image_bytes.size : 0
        @content_type = response.header['content-type']
      rescue => ex
        raise "Invalid Response: #{ex.message}"
      end
    end

    def save(path)
      File.open(path, 'wb') { |s| s.write(@image_bytes) }
    end

  end
end
