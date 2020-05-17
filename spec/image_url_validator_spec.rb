require 'spec_helper'
require './lib/image_url_validator'

describe ImageUrlValidator do
  describe '#validate' do
    subject { described_class.new(url: url_param).validate }

    context 'when url has http scheme' do
      context 'and jpg extension' do
        let(:url_param) { 'http://some.pic/pic.jpg' }

        it { is_expected.to be_truthy }
      end

      context 'and jpeg extension' do
        let(:url_param) { 'http://some.pic/pic.jpeg' }

        it { is_expected.to be_truthy }
      end

      context 'and png extension' do
        let(:url_param) { 'http://some.pic/pic.png' }

        it { is_expected.to be_truthy }
      end

      context 'and gif extension' do
        let(:url_param) { 'http://some.pic/pic.gif' }

        it { is_expected.to be_truthy }
      end

      context 'and some not image related uri' do
        let(:url_param) { 'http://some.pic/pic' }

        it { is_expected.to be_falsey }
      end
    end

    context 'when url has data scheme' do
      context 'and correct data url' do
        let(:url_param) { 'data:image/jpeg;base64,base64encoded:string' }

        it { is_expected.to be_truthy }
      end

      context 'and incorrect data url' do
        let(:url_param) { 'data:plain/txt;base64,base64encoded:string' }

        it { is_expected.to be_falsey }
      end
    end
  end
end
