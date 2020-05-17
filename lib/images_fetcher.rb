require './lib/image_url/validator'
require './lib/image_url/processor'

class ImagesFetcher
  attr_reader :file_path, :errors

  def initialize(file_path:)
    @file_path = file_path
    @errors = {
      url_validation: [],
      processing: []
    }
  end

  def perform
    File.foreach(file_path).each_with_index do |line, idx|
      url = line.chomp
      validator = ImageUrl::Validator.new(url: url)

      next errors[:url_validation] << url unless validator.validate

      next if ImageUrl::Processor.new(url: url,
                                      file_name: "#{idx}.#{validator.ext}",
                                      is_data_url: validator.is_base64)
                                 .save

      errors[:processing] << url
    end
  rescue Errno::ENOENT
    puts 'Invalid file path provided.'
  end

  def display_errors
    return unless errors

    errors.each do |error_type, urls|
      next if urls.empty?

      puts "===== Urls failed during #{error_type.to_s.gsub('_', ' ')} ====="
      urls.each { |url| puts " - #{url}" }
      puts
    end
  end
end
