FactoryBot.define do
  factory :cep_search do
    number { "00000-000" }
    state { "a" }
    address { "Rua X" }
    district { "Bairro Y" }
    city { "Cidade Z" }
    ddd { "99" }
    count { 1 }
  end
end
