class CepSearch < ApplicationRecord
  validates_uniqueness_of :number, case_sensitive: false

  scope :most_searched_ceps, -> { order(count: :asc).last(5).reverse }
  scope :most_searched_ceps_from_each_state, -> {
    pluck(:uf).uniq.map { |uf| CepSearch.where(uf: uf).order(count: :asc).last }
  }
end
