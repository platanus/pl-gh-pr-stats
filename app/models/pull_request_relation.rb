class PullRequestRelation < ApplicationRecord
  belongs_to :pull_request
  belongs_to :github_user

  validates :relation_type, presence: true
  validates_inclusion_of :relation_type, in: %w(assignee reviewer)
end

# == Schema Information
#
# Table name: pull_request_relations
#
#  id              :integer          not null, primary key
#  pull_request_id :integer
#  github_user_id  :integer
#  relation_type   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_pull_request_relations_on_github_user_id   (github_user_id)
#  index_pull_request_relations_on_pull_request_id  (pull_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (github_user_id => github_users.id)
#  fk_rails_...  (pull_request_id => pull_requests.id)
#
