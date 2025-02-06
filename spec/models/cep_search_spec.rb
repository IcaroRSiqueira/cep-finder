require 'rails_helper'

RSpec.describe CepSearch, type: :model do
  describe 'ActiveRecord' do
    context 'Validations' do
      it { is_expected.to validate_uniqueness_of(:number) }
    end
    context 'Database columns/indexes' do
      it { is_expected.to have_db_column(:number).of_type(:string) }
      it { is_expected.to have_db_column(:uf).of_type(:string) }
      it { is_expected.to have_db_column(:count).of_type(:integer) }
    end
  end
end
