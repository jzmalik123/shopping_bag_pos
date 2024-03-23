# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?
BagCategory.create!(name: 'Fouji Shopping Bag')
BagCategory.create!(name: 'Vicky Shopping Bag') 
BagSize.create!(size: '7 X 9')
BagSize.create!(size: '8 X 11')
BagSize.create!(size: '10 X 13')
BagSize.create!(size: '12 X 15')
BagSize.create!(size: '15 X 18')
BagSize.create!(size: '18 X 21')
BagSize.create!(size: '18 X 26')
