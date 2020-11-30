require "csv"
media_file = Rails.root.join("db", "media_seeds.csv")

user = User.new(username: "ayesha-asif", uid: 12345678, provider: "github", email: "ayaseef@gmail.com", name: nil)
user.save!

CSV.foreach(media_file, headers: true, header_converters: :symbol, converters: :all) do |row|
  data = Hash[row.headers.zip(row.fields)]
  puts data
  data[:user_id] = user.id
  Work.create!(data)
end
