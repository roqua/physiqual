# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
module Physiqual
  puts 'Running seeds'
  if Rails.env.development? || Rails.env.test?
    User.find_or_create_by(user_id: 'a')
    User.find_or_create_by(user_id: 'b')
    User.find_or_create_by(user_id: 'c')
  end
  puts 'Initializing Cassandra'
  connection = CassandraConnection.instance
  connection.init_db
end
