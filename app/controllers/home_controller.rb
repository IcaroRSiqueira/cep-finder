class HomeController < ApplicationController
  before_action :set_most_searched_ceps

  def index
    @address_info = set_address_info(update_count: false) if params.dig(:cep, :number).present?
    @error_message = params[:error_message]
  rescue Cep::Exception => e
    @error_message = e.message
  end

  def create
    @address_info = set_address_info(update_count: true)

    redirect_to action: "index", cep: { number: params.dig(:cep, :number) }
  rescue Cep::Exception => e
    redirect_to action: "index", error_message: e.message
  end

  private

  def set_most_searched_ceps
    @most_searched_ceps = CepSearch.most_searched_ceps
    @most_searched_ceps_from_each_state = CepSearch.most_searched_ceps_from_each_state
  end

  def set_address_info(update_count:)
    Cep::Client.address_info_by_cep(cep_number: params[:cep][:number],  update_count: update_count)
  end
end
