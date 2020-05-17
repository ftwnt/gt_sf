module ImageUrl
  class Validator
    attr_reader :url, :ext, :is_base64

    def initialize(url:)
      @url = url
    end

    def validate
      validation = base64_check
      if validation.nil?
        validation = url_basic_check
      else
        @is_base64 = true
      end

      validation && (@ext = validation[:ext])
    end

    private

    def url_pattern
      @url_pattern ||= /http(s?):\/\/.*\.(?<ext>(#{allowed_extensions_regex}))/
    end

    def url_basic_check
      url_pattern.match url
    end

    def data_url_pattern
      @data_url_pattern ||= /data:image\/(?<ext>(#{allowed_extensions_regex}));base64,.*/
    end

    def base64_check
      data_url_pattern.match url
    end

    def allowed_extensions_regex
      allowed_extensions.join('|')
    end

    def allowed_extensions
      %w[
        jpg
        jpeg
        png
        gif
      ]
    end
  end
end
