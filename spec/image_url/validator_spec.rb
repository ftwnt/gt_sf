require 'spec_helper'
require './lib/image_url/validator'

describe ImageUrl::Validator do
  describe '#validate' do
    let(:validator) { described_class.new(url: url_param) }
    let(:extension_result) { validator.ext }
    let(:base64_flag) { validator.is_base64 }
    subject { validator.validate }

    context 'when url has http scheme' do
      context 'and jpg extension' do
        let(:file_ext) { 'jpg' }
        let(:url_param) { "http://some.pic/pic.#{file_ext}" }

        it { is_expected.to be_truthy }
        it 'stores correct file extension' do
          subject
          expect(extension_result).to eq file_ext
        end
        it 'does not store base64 flag' do
          subject
          expect(base64_flag).to be_nil
        end
      end

      context 'and jpeg extension' do
        let(:file_ext) { 'jpeg' }
        let(:url_param) { "http://some.pic/pic.#{file_ext}" }

        it { is_expected.to be_truthy }
        it 'stores correct file extension' do
          subject
          expect(extension_result).to eq file_ext
        end
        it 'does not store base64 flag' do
          subject
          expect(base64_flag).to be_nil
        end
      end

      context 'and png extension' do
        let(:file_ext) { 'png' }
        let(:url_param) { "http://some.pic/pic.#{file_ext}" }

        it { is_expected.to be_truthy }
        it 'stores correct file extension' do
          subject
          expect(extension_result).to eq file_ext
        end
        it 'does not store base64 flag' do
          subject
          expect(base64_flag).to be_nil
        end
      end

      context 'and gif extension' do
        let(:file_ext) { 'gif' }
        let(:url_param) { "http://some.pic/pic.#{file_ext}" }

        it { is_expected.to be_truthy }
        it 'stores correct file extension' do
          subject
          expect(extension_result).to eq file_ext
        end
        it 'does not store base64 flag' do
          subject
          expect(base64_flag).to be_nil
        end
      end

      context 'and some not image related uri' do
        let(:url_param) { 'http://some.pic/pic' }

        it { is_expected.to be_falsey }
        it 'has no extension stored' do
          subject
          expect(extension_result).to be_nil
        end
        it 'does not store base64 flag' do
          subject
          expect(base64_flag).to be_nil
        end
      end
    end

    context 'when url has data scheme' do
      context 'and correct data url' do
        let(:file_ext) { 'jpeg' }
        let(:url_param) { "data:image/#{file_ext};base64,base64encoded:string" }

        it { is_expected.to be_truthy }
        it 'stores correct file extension' do
          subject
          expect(extension_result).to eq file_ext
        end
        it 'stores base64 flag' do
          subject
          expect(base64_flag).to be_truthy
        end
      end

      context 'and incorrect data url' do
        let(:file_ext) { 'txt' }
        let(:url_param) { "data:plain/#{file_ext};base64,base64encoded:string" }

        it { is_expected.to be_falsey }
        it 'has no extension stored' do
          subject
          expect(extension_result).to be_nil
        end
        it 'stores base64 flag' do
          subject
          expect(base64_flag).to be_nil
        end
      end
    end
  end
end
