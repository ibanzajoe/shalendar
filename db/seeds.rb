begin

# add default admin user
user = User.new
user.email = 'test@test.com'
user.first_name = 'Jae'
user.last_name = 'Lee'
user.username = 'jae'
user.password = 'asdfasdf'
user.password_confirmation = user.password
user.role = 'admin'
user.provider = 'email'
user.avatar_url = '/vendor/honeybadger/img/avatar.jpg'
user.save


rescue Exception => e
    puts "seeds already ran"
end
