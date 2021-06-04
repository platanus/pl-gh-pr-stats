FactoryBot.define do
  factory :preference do
    association :user

    default_organization_id { 1 }
    default_team_id { 1 }
    default_time { 0 }
  end
end
