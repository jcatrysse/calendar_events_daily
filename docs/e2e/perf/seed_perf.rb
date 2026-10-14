User.current = User.find_by!(login: 'admin')
project = Project.find_by!(identifier: 'e2e-project')
users = User.where(login: %w[manager reporter admin]).to_a
month = Date.civil(Date.today.year, Date.today.month, 1)
rng = Random.new(42)
existing = Issue.where(project_id: project.id).where('subject LIKE ?', 'Perf %').count
(existing...400).each do |n|
  start = month - 20 + rng.rand(45)
  Issue.create!(project: project, tracker: project.trackers.first, subject: "Perf #{n}", author: User.current,
                priority: IssuePriority.default || IssuePriority.first, status: project.trackers.first.default_status,
                assigned_to: users[n % users.size], start_date: start, due_date: start + 3 + rng.rand(40))
end
puts "perf issues: #{Issue.where('subject LIKE ?', 'Perf %').count}"
