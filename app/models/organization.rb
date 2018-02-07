class Organization < ApplicationRecord
  include PowerTypes::Observable

  has_many :repositories
  has_many :hooks, as: :resource

  validates :gh_id, presence: true
  validates :login, presence: true

  def reviewers
    GithubUser
      .joins(pull_requests_reviewed: :repository)
      .where(pull_requests_reviewed: { repositories: { organization_id: id } })
      .group(:id)
  end

  def merge_users
    GithubUser
      .joins(pull_requests_merged: :repository)
      .where(pull_requests_merged: { repositories: { organization_id: id } })
      .group(:id)
  end

  def pull_request_owners
    GithubUser
      .joins(pull_requests: :repository)
      .where(pull_requests: { repositories: { organization_id: id } })
      .group(:id)
  end

  def all_tracked_users
    pull_request_owners.tracked | reviewers.tracked | merge_users.tracked
  end
end

# == Schema Information
#
# Table name: organizations
#
#  id          :integer          not null, primary key
#  gh_id       :integer
#  login       :string
#  description :string
#  html_url    :string
#  avatar_url  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  name        :string
#  tracked     :boolean
#
