json.groups @downlines do |downline|
  json.partial! 'api/v1/user/groups/user', user: downline
  # json.personal_sales downline.current_settlement&.personal_sales || Money.new(0)
  # json.group_sales downline.current_settlement&.group_sales || Money.new(0)
  # json.total_sales (downline.current_settlement&.group_sales || Money.new(0)) + (downline.current_settlement&.personal_sales || Money.new(0))

  downline_current_sales = downline.current_sales
  json.personal_sales downline_current_sales[:personal_sales]
  json.downline_sales downline_current_sales[:downline_sales]
  json.group_sales downline_current_sales[:group_sales]

  downline_downlines = @downlines_downlines.select { |d| d.upline_id == downline.id }

  json.downlines downline_downlines do |d|
    json.partial! 'api/v1/user/groups/user', user: d
  end

  json.downlines_count downline_downlines.size
end