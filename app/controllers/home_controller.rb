class HomeController < ApplicationController
  before_action :set_most_searched_ceps

  def index
    @address_info = Cep::Client.address_info_by_cep(params[:cep][:number]) if params.dig(:cep, :number).present?
  rescue Cep::Exception => e
    @error_message = e.message
  end

  def set_most_searched_ceps
    @most_searched_ceps = CepSearch.most_searched_ceps
    @most_searched_ceps_from_each_state = CepSearch.most_searched_ceps_from_each_state
  end
end
