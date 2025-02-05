module Cep
  class Client
    CLIENT_API_BASE_URL = "https://cep.awesomeapi.com.br"
    class << self
      def address_info_by_cep(cep_number)
        raise_error("CEP precisa ser preenchido", :unprocessable_entity) unless cep_number.present?
        normalize_cep(cep_number) unless cep_formatted?(cep_number)

        response = get_request("/json/#{cep_number}")
        raise_error(JSON(response.body)["message"], response.status) unless response&.status == 200

        JSON.parse(response.body, symbolize_names: true)
      end

      private

      def get_request(path)
        Faraday.get("#{CLIENT_API_BASE_URL}#{path}")
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
    end
  end
end
