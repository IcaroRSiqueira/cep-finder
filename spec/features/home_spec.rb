require 'rails_helper'

describe 'visiting home page', type: :feature do
  context 'when searching for cep' do
    before do
      stub_request(:get, request_url).to_return(body: response_body.to_json, status: status)
    end

    let(:request_url) do
      'https://cep.awesomeapi.com.br/json/66635-087'
    end

    let(:response_body) do
      {
        cep: '66635087',
        address_type: 'Quadra',
        address_name: 'Doze',
        address: 'Quadra Doze',
        state: 'PA',
        district: 'Parque Verde',
        lat: '-1.3780219',
        lng: '-48.4367779',
        city: 'Belém',
        city_ibge: '1501402',
        ddd: '91'
      }
    end

    let(:status) { 200 }

    context 'and cep provided is correct' do
      it 'returns address info correctly' do
        visit '/'
        fill_in 'cep_number', with: '66635-087'
        click_on 'Buscar'
        expect(page).to have_content 'CEP: 66635087'
        expect(page).to have_content 'Endereço: Quadra Doze'
        expect(page).to have_content 'Bairro: Parque Verde'
        expect(page).to have_content 'Cidade: Belém'
        expect(page).to have_content 'Estado: PA'
        expect(page).to have_content 'DDD: 91'
      end
    end

    context 'and cep is invalid' do
      it 'returns error message' do
        visit '/'
        fill_in 'cep_number', with: 'INVALIDO'
        click_on 'Buscar'
        expect(page).to have_content 'CEP inválido: INVALIDO'
      end
    end

    context 'and cep does not exists' do
      let(:request_url) do
        'https://cep.awesomeapi.com.br/json/00000-000'
      end

      let(:response_body) do
        {
          code: "not_found",
          message: "O CEP 00000-000 nao foi encontrado"
        }
      end

      let(:status) { 404 }

      it 'returns error message' do
        visit '/'
        fill_in 'cep_number', with: '00000-000'
        click_on 'Buscar'
        expect(page).to have_content 'O CEP 00000-000 nao foi encontrado'
      end
    end
  end

  context 'when visualizing most searched ceps info' do
    context 'and there are searched ceps info' do
      before do
        create(:cep_search, number: '66635-087', uf: 'PA', count: 5)
        create(:cep_search, number: '55038-100', uf: 'PE', count: 6)
        create(:cep_search, number: '53620-378', uf: 'PE', count: 2)
        create(:cep_search, number: '59547-970', uf: 'RN', count: 3)
        create(:cep_search, number: '22713-080', uf: 'RJ', count: 8)
        create(:cep_search, number: '09841-280', uf: 'SP', count: 15)
        create(:cep_search, number: '25550-350', uf: 'SP', count: 2)
        create(:cep_search, number: '13272-006', uf: 'SP', count: 1)
      end

      it 'shows the first 5 most searched ceps ranked' do
        visit '/'

        expect(page).to have_content '1 - 09841-280'
        expect(page).to have_content '2 - 22713-080'
        expect(page).to have_content '3 - 55038-100'
        expect(page).to have_content '4 - 66635-087'
        expect(page).to have_content '5 - 59547-970'
        expect(page).not_to have_content '25550-350'
        expect(page).not_to have_content '13272-006'
        expect(page).not_to have_content '53620-378'
      end

      it 'shows the most searched cep for each state' do
        visit '/'

        expect(page).to have_content 'SP - 09841-280'
        expect(page).to have_content 'RJ - 22713-080'
        expect(page).to have_content 'RN - 59547-970'
        expect(page).to have_content 'PE - 55038-100'
        expect(page).to have_content 'PA - 66635-087'
        expect(page).not_to have_content '25550-350'
        expect(page).not_to have_content '25550-350'
        expect(page).not_to have_content '53620-378'
      end
    end
  end
end
