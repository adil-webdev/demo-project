# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

# Create users
puts "Creating users..."
admin = User.create!(
  name: "Admin User",
  email: "admin@example.com",
  password: "admin123",
  password_confirmation: "admin123",
  role: "admin",
  premium: true,
  membership_expires_at: 1.year.from_now
)

john = User.create!(
  name: "John Doe",
  email: "john@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "user",
  premium: false
)

jane = User.create!(
  name: "Jane Smith",
  email: "jane@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "user",
  premium: true,
  membership_expires_at: 6.months.from_now
)

# Create posts
puts "Creating posts..."
post1 = Post.create!(
  user: admin,
  title: "Welcome to SonarQube Demo",
  content: "This is a demo application for showcasing SonarQube code analysis capabilities.",
  status: "published",
  views_count: 150
)

post2 = Post.create!(
  user: john,
  title: "Understanding Code Quality",
  content: "Code quality is essential for maintaining a healthy codebase.",
  status: "published",
  views_count: 75
)

post3 = Post.create!(
  user: jane,
  title: "Understanding Security Vulnerabilities",
  content: "Learn about common security vulnerabilities and how to prevent them.",
  status: "published",
  views_count: 200
)

post4 = Post.create!(
  user: john,
  title: "Draft Post About Testing",
  content: "This is a draft post about testing best practices.",
  status: "draft",
  views_count: 0
)

# Create comments
puts "Creating comments..."
Comment.create!(
  user: john,
  post: post1,
  content: "Great introduction to SonarQube!",
  status: "approved"
)

Comment.create!(
  user: jane,
  post: post1,
  content: "Very helpful demo, thanks for sharing.",
  status: "approved"
)

Comment.create!(
  user: admin,
  post: post2,
  content: "Nice explanation of code quality concepts.",
  status: "approved"
)

Comment.create!(
  user: john,
  post: post3,
  content: "Very informative! Thanks for sharing.",
  status: "pending"
)

Comment.create!(
  user: jane,
  post: post3,
  content: "Security is so important in modern applications.",
  status: "approved"
)

puts "Seed data created successfully!"
puts "=" * 60
puts "Total Users: #{User.count}"
puts "Total Posts: #{Post.count}"
puts "Total Comments: #{Comment.count}"
puts "=" * 60
