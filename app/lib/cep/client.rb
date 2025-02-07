module Cep
  class Client
    CLIENT_API_BASE_URL = "https://cep.awesomeapi.com.br"
    class << self
      def address_info_by_cep(cep_number)
        raise_error("CEP precisa ser preenchido", :unprocessable_entity) unless cep_number.present?
        normalize_cep(cep_number) unless cep_formatted?(cep_number)
        return existing_address_info(cep_number) if existing_cep_search(cep_number).present?

        response = get_request("/json/#{cep_number}")
        created_cep_search = register_searched_information(cep_number, response)
        created_cep_search.default_attributes
      end

      private

      def get_request(path)
        response = Faraday.get("#{CLIENT_API_BASE_URL}#{path}")
        raise_error(JSON(response.body)["message"], response.status) unless response&.status == 200

        JSON.parse(response.body, symbolize_names: true)
      end

      def normalize_cep(cep_number)
        cep_number.insert(-4, "-") if cep_with_only_digits?(cep_number)
        return if cep_formatted?(cep_number)

        raise_error("CEP inválido: #{cep_number}", :unprocessable_entity)
      end

      def cep_formatted?(cep_number)
        cep_number.match?(/^[0-9]{5}\-[0-9]{3}$/)
      end

      def cep_with_only_digits?(cep_number)
        cep_number.match?(/[0-9]{8}$/)
      end

      def raise_error(message, status)
        raise Cep::Exception.new(message, status)
      end

      def register_searched_information(cep_number, response)
        CepSearch.create!(
          number: cep_number,
          address: response[:address],
          state: response[:state],
          district: response[:district],
          city: response[:city],
          ddd: response[:ddd],
          count: 1
        )
      end

      def existing_address_info(cep_number)
        cep_search = existing_cep_search(cep_number)
        cep_search.increment!(:count)
        cep_search.default_attributes
      end

      def existing_cep_search(cep_number)
        CepSearch.find_by_number(cep_number)
      end
    end
  end
end
