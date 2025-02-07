class CepSearch < ApplicationRecord
  validates_uniqueness_of :number, case_sensitive: false

  scope :most_searched_ceps, -> { order(count: :asc).last(5).reverse }
  scope :most_searched_ceps_from_each_state, -> {
    pluck(:state).uniq.map { |state| CepSearch.where(state: state).order(count: :asc).last }
  }

  def default_attributes
    attributes.symbolize_keys.except(:id, :created_at, :updated_at)
  end
end
