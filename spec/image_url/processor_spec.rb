require 'spec_helper'

require './lib/image_url/processor'

describe ImageUrl::Processor do
  describe '#save' do
    let(:url) { 'http://some.domain/and.image' }
    let(:file_name) { 'some_name' }
    let(:is_data_url) { false }
    let(:processor) do
      described_class.new(
        url: url,
        file_name: file_name,
        is_data_url: is_data_url
      )
    end
    let(:stubbed_file) { instance_double('opened file', write: true) }
    subject { processor.save }

    before do
      allow(File).to receive(:open).with(file_name, 'wb') { |&block| block.call(stubbed_file) }
    end

    context 'when url has data scheme' do
      let(:is_data_url) { true }
      let(:decoded_string) { 'some_string' }
      let(:data_url_part) { 'data:image/jpeg;base64,' }
      let(:url) { "#{data_url_part}encoded.image" }

      before do
        allow(url).to receive(:[]).with(described_class::BASE64_URL_PATTERN) { data_url_part }
        allow(url).to receive(:[]).with(data_url_part.length..-1) { decoded_string }
        allow(Base64).to receive(:decode64) { decoded_string }
      end

      it 'opens temp file for writting' do
        expect(File).to receive(:open).with(file_name, 'wb')

        subject
      end

      it 'decodes the url content' do
        expect(url).to receive(:[]).with(described_class::BASE64_URL_PATTERN)
        expect(url).to receive(:[]).with(data_url_part.length..-1)
        expect(Base64).to receive(:decode64).with(decoded_string)

        subject
      end

      it 'writes to a new file' do
        expect(stubbed_file).to receive(:write).with(decoded_string)

        subject
      end

      it { is_expected.to be_truthy }
    end

    context 'when url is not data scheme related' do
      let(:url) { 'http://some.domain/some-image.jpg' }
      let(:stubbed_request_content) { 'stubbed_request_content' }
      let(:stubbed_request) do
        instance_double('stubbed_request', read: stubbed_request_content)
      end

      before do
        allow(processor).to receive(:open) { stubbed_request }
      end

      it 'opens temp file for writting' do
        expect(File).to receive(:open).with(file_name, 'wb')

        subject
      end

      it 'opens request and retrieves content' do
        expect(processor).to receive(:open).with(url)
        expect(stubbed_request).to receive(:read)

        subject
      end

      it 'writes to a new file' do
        expect(stubbed_file).to receive(:write).with(stubbed_request_content)

        subject
      end

      it { is_expected.to be_truthy }
    end
  end
end
