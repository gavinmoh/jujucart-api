json.extract! user, :id, :name, :email, :phone_number, :referral_code, :activated_at, :profile_photo
json.role_name user.try(:role).try(:name)
json.role do
  if user.role
    json.partial! 'api/v1/user/groups/role', role: user.try(:role)
  else
    nil
  end
end