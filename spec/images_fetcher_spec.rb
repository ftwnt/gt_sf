require 'spec_helper'
require 'tempfile'

require './lib/images_fetcher'

describe ImagesFetcher do
  describe '#perform' do
    let(:tmp_file_lines) do
      %W[
        line_1\n
        line_2\n
        line_3\n
      ]
    end
    let(:tmp_file) do
      file = Tempfile.new('foo')
      tmp_file_lines.each { |line| file.write line }
      file
    end
    let(:fetcher) { described_class.new(file_path: tmp_file.path) }

    let(:validator_stub) do
      instance_double('ImageUrl::Validator', validate: true, ext: 'some', is_base64: false)
    end
    let(:processor_stub) { instance_double('ImageUrl::Processor', save: true) }

    subject { fetcher.perform }

    before do
      allow(File).to receive(:foreach) { tmp_file_lines }
      allow(ImageUrl::Validator).to receive(:new) { validator_stub }
      allow(ImageUrl::Processor).to receive(:new) { processor_stub }
    end

    it 'opens a file' do
      expect(File).to receive(:foreach).with(tmp_file.path)

      subject
    end

    it 'removes line break on each line' do
      expect(tmp_file_lines[0]).to receive(:chomp)
      expect(tmp_file_lines[1]).to receive(:chomp)
      expect(tmp_file_lines[2]).to receive(:chomp)

      subject
    end

    it 'validates each line' do
      expect(ImageUrl::Validator).to receive(:new).with(url: tmp_file_lines[0].chomp)
      expect(ImageUrl::Validator).to receive(:new).with(url: tmp_file_lines[1].chomp)
      expect(ImageUrl::Validator).to receive(:new).with(url: tmp_file_lines[2].chomp)
      expect(validator_stub).to receive(:validate).exactly(3).times

      subject
    end

    context 'when all urls are valid' do
      context 'and all urls could be processed' do
        it 'processes all urls' do
          expect(processor_stub).to receive(:save).exactly(3).times

          subject
        end
      end

      context 'and not all urls could be processed' do
        let(:failed_url) { tmp_file_lines[0].chomp }
        let(:failed_processor_stub) { instance_double('ImageUrl::Processor', save: false) }
        let(:expected_errors) do
          {
            url_validation: [],
            processing: [failed_url]
          }
        end

        before do
          allow(ImageUrl::Processor)
            .to receive(:new)
              .with(hash_including(url: failed_url)) { failed_processor_stub }
        end

        it 'processes urls' do
          expect(processor_stub).to receive(:save).twice

          subject
        end

        it 'stores errors for failed processing' do
          subject

          expect(fetcher.errors).to eq expected_errors
        end
      end
    end

    context 'when not all urls are valid' do
      let(:failed_url_1) { tmp_file_lines[0].chomp }
      let(:failed_url_2) { tmp_file_lines[1].chomp }
      let(:failed_validator_stub) do
        instance_double('ImageUrl::Validator', validate: false, ext: 'some', is_base64: false)
      end
      let(:expected_errors) do
        {
          url_validation: [failed_url_1, failed_url_2],
          processing: []
        }
      end

      before do
        allow(ImageUrl::Validator)
          .to receive(:new).with(hash_including(url: failed_url_1)) { failed_validator_stub }
        allow(ImageUrl::Validator)
          .to receive(:new).with(hash_including(url: failed_url_2)) { failed_validator_stub }
      end

      it 'processes available urls' do
        expect(processor_stub).to receive(:save).once

        subject
      end

      it 'stores errors for failed processing' do
        subject

        expect(fetcher.errors).to eq expected_errors
      end
    end
  end

  describe '#display_errors' do
    let(:fetcher) { described_class.new(file_path: 'some_path') }
    subject { fetcher.display_errors }

    context 'when errors empty' do
      it 'does not print any info' do
        expect(fetcher).to_not receive(:puts)

        subject
      end
    end

    context 'when errors exist' do
      let(:validation_header_message) { '===== Urls failed during url validation =====' }
      let(:processing_header_message) { '===== Urls failed during processing =====' }
      let(:validation_error_url) { 'http://validation-example.com' }
      let(:processing_error_url) { 'http://processing-example.com' }
      before do
        fetcher.errors[:url_validation] << validation_error_url
        fetcher.errors[:processing] << processing_error_url
      end

      it 'prints info' do
        expect(fetcher).to receive(:puts).with(validation_header_message)
        expect(fetcher).to receive(:puts).with(" - #{validation_error_url}")
        expect(fetcher).to receive(:puts).with(no_args)
        expect(fetcher).to receive(:puts).with(processing_header_message)
        expect(fetcher).to receive(:puts).with(" - #{processing_error_url}")
        expect(fetcher).to receive(:puts).with(no_args)

        subject
      end
    end
  end
end
