require 'digest/sha1'

# Set time zone for Rails environment
Time.zone = 'UTC'

user = User.new(
  login: 'admin',
  password: 'admin',
  password_confirmation: 'admin',
  is_admin: true,
  first_name: 'Admin',
  last_name: 'User'
)
user.auth_type = 'database'
# Generate token manually to avoid Time.zone issues
user.token = Digest::SHA1.hexdigest("#{Time.now.to_i}#{rand}")
user.save!(validate: false)

# Create user preferences (required for login)
Preference.create!(user: user)

puts 'Admin user created successfully: admin/admin'
