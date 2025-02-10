require 'rails_helper'

RSpec.describe CepService::ExternalClient do
  describe '.get_address_info_by_cep' do
    subject { described_class.get_address_info_by_cep(cep_number) }

    let(:request_url) do
      "https://cep.awesomeapi.com.br/json/#{cep_number}"
    end

    let(:response_body) do
      {
        cep: "66635087",
        address_type: "Quadra",
        address_name: "Doze",
        address: "Quadra Doze",
        state: "PA",
        district: "Parque Verde",
        lat: "-1.3780219",
        lng: "-48.4367779",
        city: "Belém",
        city_ibge: "1501402",
        ddd: "91"
      }
    end

    before do
      stub_request(:get, request_url).to_return(body: response_body.to_json, status: status)
    end

    context 'when cep is found' do
      let(:status) { 200 }
      let(:cep_number) { '66635-087' }
      it 'calls cep api with correct params' do
        subject

        expect(a_request(:get, request_url)).to have_been_made.once
      end

      it 'returns response body' do
        expect(subject).to eq(response_body)
      end
    end

    context 'when cep api returns an error' do
      let(:cep_number) { '00000-000' }

      context 'because cep number does not exists' do
        let(:status) { 404 }
        let(:response_body) do
          {
            code: "not_found",
            message: "O CEP 00000000 nao foi encontrado"
          }
        end

        it 'raises an error' do
          expect { subject }.to raise_error(CepService::Exception, "O CEP 00000000 nao foi encontrado")
        end
      end

      context 'because some generic error occurs on server' do
        let(:status) { 500 }
        let(:response_body) do
          {
            code: "generic_error",
            message: "Internal Server Error"
          }
        end

        it 'raises an error' do
          expect { subject }.to raise_error(CepService::Exception, "Internal Server Error")
        end
      end
    end
  end
end
