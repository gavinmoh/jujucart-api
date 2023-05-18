json.group do
  json.partial! 'api/v1/user/groups/user', user: @group

  # json.personal_sales @group.current_settlement&.personal_sales || Money.new(0)
  # json.group_sales @group.current_settlement&.group_sales || Money.new(0)
  # json.total_sales (@group.current_settlement&.group_sales || Money.new(0)) + (@group.current_settlement&.personal_sales || Money.new(0))
  
  # json.downlines @group_downlines do |d|
  #   json.partial! 'api/v1/user/groups/user', user: d
  #   json.personal_sales d.current_settlement&.personal_sales || Money.new(0)
  #   json.group_sales d.current_settlement&.group_sales || Money.new(0)
  #   json.total_sales (d.current_settlement&.group_sales || Money.new(0)) + (d.current_settlement&.personal_sales || Money.new(0))
  # end
  
  downline_current_sales = @group.current_sales
  json.personal_sales downline_current_sales[:personal_sales]
  json.downline_sales downline_current_sales[:downline_sales]
  json.group_sales downline_current_sales[:group_sales]

  json.downlines @group_downlines do |d|
    json.partial! 'api/v1/user/groups/user', user: d
    d_current_sales = d.current_sales
    json.personal_sales d_current_sales[:personal_sales]
    json.downline_sales d_current_sales[:downline_sales]
    json.group_sales d_current_sales[:group_sales]
  end
end