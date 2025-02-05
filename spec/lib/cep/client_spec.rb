require 'rails_helper'

RSpec.describe Cep::Client do
  describe '.address_info_by_cep' do
    subject { described_class.address_info_by_cep(cep_number) }

    let(:request_url) do
      "https://cep.awesomeapi.com.br/json/#{normalized_cep_number}"
    end

    let(:response_double) do
      double('Faraday::Response', body: response_body.to_json, status: 200)
    end

    let(:connection_double) do
      let(double)
    end
    let(:normalized_cep_number) { '66635-087' }

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
      stub_request(:get, request_url).to_return(body: response_body.to_json)
    end

    context 'when cep is in correct format' do
      context 'and is provided numbers with hyphen' do
        let(:cep_number) { '66635-087' }

        it 'calls cep api with correct params' do
          subject

          expect(a_request(:get, request_url)).to have_been_made.once
        end

        it 'returns response body' do
          expect(subject).to eq(response_body)
        end
      end

      context 'and is provided only numbers' do
        let(:cep_number) { '66635087' }

        it 'calls cep api with correct params' do
          subject

          expect(a_request(:get, request_url)).to have_been_made.once
        end

        it 'returns response body' do
          expect(subject).to eq(response_body)
        end
      end
    end

    context 'when cep has invalid format' do
      context 'because it has more digits' do
        let(:cep_number) { '66635-0871' }
        let(:normalized_cep_number) { '66635-0871' }

        it 'does not call cep api and raises an error' do
          expect { subject }.to raise_error(Cep::Exception, "Invalid CEP: #{cep_number}")

          expect(a_request(:get, request_url)).not_to have_been_made
        end
      end

      context 'because it has fewer digits' do
        let(:cep_number) { '66635-08' }
        let(:normalized_cep_number) { '66635-08' }

        it 'does not call cep api and raises an error' do
          expect { subject }.to raise_error(Cep::Exception, "Invalid CEP: #{cep_number}")

          expect(a_request(:get, request_url)).not_to have_been_made
        end
      end

      context 'because it has hypen in wrong place' do
        let(:cep_number) { '666-35087' }
        let(:normalized_cep_number) { '666-35087' }

        it 'does not call cep api and raises an error' do
          expect { subject }.to raise_error(Cep::Exception, "Invalid CEP: #{cep_number}")

          expect(a_request(:get, request_url)).not_to have_been_made
        end
      end

      context 'because it has letters' do
        let(:cep_number) { '66635-ABC' }
        let(:normalized_cep_number) { '66635-ABC' }

        it 'does not call cep api and raises an error' do
          expect { subject }.to raise_error(Cep::Exception, "Invalid CEP: #{cep_number}")

          expect(a_request(:get, request_url)).not_to have_been_made
        end
      end

      context 'because is not provided' do
        let(:cep_number) { nil }
        let(:normalized_cep_number) { nil }

        it 'does not call cep api and raises an error' do
          expect { subject }.to raise_error(Cep::Exception, "CEP must be present")

          expect(a_request(:get, request_url)).not_to have_been_made
        end
      end
    end

    context 'when cep api returns an error' do
      before do
        stub_request(:get, request_url).to_return(body: response_body.to_json, status: status)
      end
      let(:cep_number) { '66635-081' }
      let(:normalized_cep_number) { '66635-081' }

      context 'because cep number does not exists' do
        let(:status) { 404 }
        let(:response_body) do
          {
            code: "not_found",
            message: "O CEP 66635081 nao foi encontrado"
          }
        end

        it 'raises an error' do
          expect { subject }.to raise_error(Cep::Exception, response_body.to_json)
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
          expect { subject }.to raise_error(Cep::Exception, response_body.to_json)
        end
      end
    end
  end
end
