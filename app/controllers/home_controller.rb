class HomeController < ApplicationController
  def index
    @address_info = Cep::Client.address_info_by_cep(params[:cep][:number]) if params.dig(:cep, :number).present?
  rescue Cep::Exception => e
    @error_message = e.message
  end
end
