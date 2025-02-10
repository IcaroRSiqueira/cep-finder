require 'rails_helper'

describe HomeController, type: :request do
  describe 'GET #index' do
    let(:cep_number) { '66635-087' }
    let(:correct_params) { { cep_number: cep_number, update_count: false } }

    before do
      allow(CepService::Finder).to receive(:find_address_info_by_cep)
    end

    it 'calls CepService::Finder with correct params' do
      get '/', params: { cep: { number: cep_number } }

      expect(CepService::Finder).to have_received(:find_address_info_by_cep).with(correct_params)
    end
  end

  describe 'POST #create' do
    let(:cep_number) { '66635-087' }
    let(:correct_params) { { cep_number: cep_number, update_count: true } }

    before do
      allow(CepService::Finder).to receive(:find_address_info_by_cep)
    end

    it 'calls CepService::Finder with correct params' do
      post '/create', params: { cep: { number: cep_number } }

      expect(CepService::Finder).to have_received(:find_address_info_by_cep).with(correct_params)
    end

    it 'redirects to index with parameters' do
      post '/create', params: { cep: { number: cep_number } }

      expect(response).to redirect_to action: :index, cep: { number: cep_number }
    end
  end
end
