class ImageUrlValidator
  attr_reader :url

  def initialize(url:)
    @url = url
  end

  def validate
    url =~ url_pattern || url =~ data_url_pattern
  end

  private

  def url_pattern
    @url_pattern ||= /http(s?):\/\/.*\.(?:#{allowed_extensions_regex})/
  end

  def data_url_pattern
    @data_url_pattern ||= /data:image\/#{allowed_extensions_regex};base64,.*/
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
