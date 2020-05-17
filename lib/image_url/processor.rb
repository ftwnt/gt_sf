require 'open-uri'
require 'base64'

module ImageUrl
  class Processor
    BASE64_URL_PATTERN = /data:image\/\w*;base64,/.freeze

    attr_reader :url, :file_name, :is_data_url

    def initialize(url:, file_name:, is_data_url:)
      @url = url
      @file_name = file_name
      @is_data_url = is_data_url
    end

    def save
      File.open(file_name, 'wb') do |new_pic|
        file_content = is_data_url ? Base64.decode64(base64_content_for(url)) : open(url).read

        new_pic.write file_content
      end

      true
    rescue
      false
    end

    private

    def base64_content_for(url)
      base64_substr = url[BASE64_URL_PATTERN]

      url[base64_substr.length..-1]
    end
  end
end
