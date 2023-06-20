FactoryBot.define do
  factory :order_attachment do
    order_id { create(:order).id }
    file { "data:image/png;base64,(#{Base64.encode64(File.open(File.join(Rails.root.join("spec/fixtures/product.png"))).read)})" }
    name { 'my photo.png' }
  end
end