class CreateCepSearches < ActiveRecord::Migration[8.0]
  def change
    create_table :cep_searches do |t|
      t.string :number
      t.string :uf
      t.integer :count

      t.timestamps
    end
  end
end
