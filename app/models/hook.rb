class Hook < ApplicationRecord
  belongs_to :repository
  validates :gh_id, presence: true
  validates :repository_id, presence: true
end

# == Schema Information
#
# Table name: hooks
#
#  id            :integer          not null, primary key
#  repo_type     :string
#  gh_id         :integer
#  name          :string
#  active        :boolean
#  ping_url      :string
#  test_url      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  repository_id :integer
#
