class CepSearch < ApplicationRecord
  validates_uniqueness_of :number
end
