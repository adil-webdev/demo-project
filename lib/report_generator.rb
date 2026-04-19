class ReportGenerator
  def self.collect_user_data(user)
    {
      name: user.name,
      email: user.email,
      created_at: user.created_at,
      posts_count: user.posts.count,
      comments_count: user.comments.count,
      role: user.role,
      premium: user.premium,
      membership_valid: user.membership_valid?,
      active: user.active?
    }
  end

  def self.generate_user_report_pdf(user)
    data = collect_user_data(user)
    report = "User Report (PDF)\n" + "=" * 50 + "\n"
    data.each { |key, value| report += "#{key.to_s.tr('_', ' ').capitalize}: #{value}\n" }
    report
  end

  def self.generate_user_report_html(user)
    data = collect_user_data(user)
    report = "<h1>User Report</h1>\n<hr>\n"
    data.each { |key, value| report += "<p>#{key.to_s.tr('_', ' ').capitalize}: #{value}</p>\n" }
    report
  end

  # INTENTIONAL MAINTAINABILITY ISSUE: High cognitive complexity
  def self.generate_post_report(post, format = "pdf")
    if format == "pdf"
      if post.status == "published"
        if post.user.premium?
          "Premium PDF Report: #{post.title} by #{post.user.name}"
        else
          "Standard PDF Report: #{post.title} by #{post.user.name}"
        end
      elsif post.status == "draft"
        if post.user.premium?
          "Draft Premium PDF: #{post.title}"
        else
          "Draft Standard PDF: #{post.title}"
        end
      else
        "Archived PDF: #{post.title}"
      end
    elsif format == "html"
      if post.status == "published"
        if post.user.premium?
          "<h1>Premium: #{post.title}</h1>"
        else
          "<h1>Standard: #{post.title}</h1>"
        end
      else
        "<h1>Basic: #{post.title}</h1>"
      end
    elsif format == "csv"
      "#{post.id},#{post.title},#{post.status}"
    else
      raise "Unknown format: #{format}"
    end
  end

  def self.generate_user_report_json(user)
    {
      name: user.name,
      email: user.email,
      created_at: user.created_at,
      posts_count: user.posts.count,
      comments_count: user.comments.count
    }.to_json
  end
end
