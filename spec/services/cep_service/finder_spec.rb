require 'rails_helper'

RSpec.describe CepService::Finder do
  describe '.find_address_info_by_cep' do
    subject { described_class.find_address_info_by_cep(cep_number: cep_number) }

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

    let(:expected_response) do
      {
        number: "66635-087",
        address: "Quadra Doze",
        state: "PA",
        district: "Parque Verde",
        city: "Belém",
        ddd: "91",
        count: 1
      }
    end

    before do
      allow(CepService::ExternalClient).to receive(:get_address_info_by_cep).with(normalized_cep_number).and_return(response_body)
    end

    context 'when cep is in correct format' do
      context 'when cep search does not exists' do
        context 'and is provided numbers with hyphen' do
          let(:cep_number) { '66635-087' }

          it 'calls external client' do
            subject

            expect(CepService::ExternalClient).to have_received(:get_address_info_by_cep)
          end

          it 'returns response body' do
            expect(subject).to eq(expected_response)
          end

          context 'when cep wasnt searched yet' do
            it 'creates new cep searched register' do
              expect { subject }.to change { CepSearch.count }.by(1)
            end

            it 'registers information correctly' do
              subject

              created_cep_search = CepSearch.last

              expect(created_cep_search.number).to eq('66635-087')
              expect(created_cep_search.state).to eq('PA')
              expect(created_cep_search.count).to eq(1)
            end
          end
        end

        context 'and is provided only numbers' do
          let(:cep_number) { '66635087' }

          it 'calls external client' do
            subject

            expect(CepService::ExternalClient).to have_received(:get_address_info_by_cep)
          end

          it 'returns response body' do
            expect(subject).to eq(expected_response)
          end

          it 'creates new cep searched register' do
            expect { subject }.to change { CepSearch.count }.by(1)
          end
        end
      end

      context 'when cep search already exists' do
        let(:cep_number) { '66635-087' }

        before do
          create(:cep_search, number: "66635-087", address: "Quadra Doze", state: "PA", district: "Parque Verde", city: "Belém", ddd: "91", count: 1)
        end

        it 'returns cep information with updated count information' do
          expect(subject[:count]).to eq(2)
        end

        it 'does not create a new cep searched register' do
          expect { subject }.not_to change { CepSearch.count }
        end

        it 'does not call external client' do
          subject

          expect(CepService::ExternalClient).not_to have_received(:get_address_info_by_cep)
        end

        context 'and update_count param is passed as false' do
          subject { described_class.find_address_info_by_cep(cep_number: cep_number, update_count: false) }

        it 'returns cep information without updating count' do
          expect(subject[:count]).to eq(1)
        end

        it 'does not create a new cep searched register' do
          expect { subject }.not_to change { CepSearch.count }
        end

        it 'does not call external client' do
          subject

          expect(CepService::ExternalClient).not_to have_received(:get_address_info_by_cep)
        end
        end
      end
    end

    context 'when cep has invalid format' do
      context 'because it has more digits' do
        let(:cep_number) { '66635-0871' }
        let(:normalized_cep_number) { '66635-0871' }

        it 'does not call external client and raises an error' do
          expect { subject }.to raise_error(CepService::Exception, "CEP inválido: #{cep_number}")

          expect(CepService::ExternalClient).not_to have_received(:get_address_info_by_cep)
        end
      end

      context 'because it has fewer digits' do
        let(:cep_number) { '66635-08' }
        let(:normalized_cep_number) { '66635-08' }

        it 'does not call external client and raises an error' do
          expect { subject }.to raise_error(CepService::Exception, "CEP inválido: #{cep_number}")

          expect(CepService::ExternalClient).not_to have_received(:get_address_info_by_cep)
        end
      end

      context 'because it has hypen in wrong place' do
        let(:cep_number) { '666-35087' }
        let(:normalized_cep_number) { '666-35087' }

        it 'does not call external client and raises an error' do
          expect { subject }.to raise_error(CepService::Exception, "CEP inválido: #{cep_number}")

          expect(CepService::ExternalClient).not_to have_received(:get_address_info_by_cep)
        end
      end

      context 'because it has letters' do
        let(:cep_number) { '66635-ABC' }
        let(:normalized_cep_number) { '66635-ABC' }

        it 'does not call external client and raises an error' do
          expect { subject }.to raise_error(CepService::Exception, "CEP inválido: #{cep_number}")

          expect(CepService::ExternalClient).not_to have_received(:get_address_info_by_cep)
        end
      end

      context 'because is not provided' do
        let(:cep_number) { nil }
        let(:normalized_cep_number) { nil }

        it 'does not call external client and raises an error' do
          expect { subject }.to raise_error(CepService::Exception, "Forneça um CEP válido")

          expect(CepService::ExternalClient).not_to have_received(:get_address_info_by_cep)
        end
      end
    end

    context 'when external client returns an error' do
      before do
        allow(CepService::ExternalClient).to receive(:get_address_info_by_cep).and_raise(CepService::Exception.new(error_message, status))
      end
      let(:cep_number) { '66635-081' }
      let(:normalized_cep_number) { '66635-081' }

      context 'because cep number does not exists' do
        let(:error_message) { "O CEP 66635081 nao foi encontrado" }
        let(:status) { 404 }

        it 'raises an error' do
          expect { subject }.to raise_error(CepService::Exception, "O CEP 66635081 nao foi encontrado")
        end
      end

      context 'because some generic error occurs on server' do
        let(:error_message) { "Internal Server Error" }
        let(:status) { 500 }

        it 'raises an error' do
          expect { subject }.to raise_error(CepService::Exception, "Internal Server Error")
        end
      end
    end
  end
end
