module CepService
  class ExternalClient
    CLIENT_API_BASE_URL = "https://cep.awesomeapi.com.br"
    class << self
      def get_address_info_by_cep(cep_number)
        get_request("/json/#{cep_number}")
      end

      private

      def get_request(path)
        response = Faraday.get("#{CLIENT_API_BASE_URL}#{path}")
        raise CepService::Exception.new(JSON(response.body)["message"], response.status) unless response&.status == 200

        JSON.parse(response.body, symbolize_names: true)
      end
    end
  end
end
