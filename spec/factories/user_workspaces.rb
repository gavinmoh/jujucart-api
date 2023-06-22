FactoryBot.define do
  factory :user_workspace do
    user_id { create(:user).id }
    workspace_id { create(:workspace).id }
    # admin { '' }
    # role { '' }
  end
end