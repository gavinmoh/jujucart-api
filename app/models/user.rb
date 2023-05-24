class User < Account
  include ActiveModel::Dirty
  devise :validatable

  has_many :assigned_stores, dependent: :destroy
  has_many :stores, through: :assigned_stores
  has_many :created_orders, foreign_key: 'created_by_id', class_name: 'Order', dependent: :restrict_with_error

  accepts_nested_attributes_for :assigned_stores, allow_destroy: true
  
  validates :name, presence: true
  validates :phone_number, uniqueness: { conditions: -> { where.not(phone_number: [nil, '']) } }, allow_blank: true, allow_nil: true
  enum role: { admin: 'admin', cashier: 'cashier' }
  validates :role, presence: true  
  
  scope :query, -> (keyword) { where('name ILIKE :keyword OR phone_number ILIKE :keyword OR email ILIKE :keyword', {keyword: "%#{keyword}%"}) }

  def reset_password_link(token)
    "#{Setting.web_host}/user/reset_password?token=#{token}"
  end

  def self.find_for_database_authentication(conditions={})
    where.not(email: [nil, '']).find_by(email: conditions[:email]) ||
    where.not(phone_number: [nil, '']).find_by(phone_number: conditions[:email])
  end
end