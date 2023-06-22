class Customer < Account
  
  belongs_to :workspace
  
  has_one :wallet, dependent: :nullify
  has_many :wallet_transactions, through: :wallet
  
  validates :name, presence: true
  validates :phone_number, uniqueness: { scope: :workspace_id }, presence: true
  
  # this block below is to replace devise :validatable
  # which doesn't work for uninqueness validation with scope
  validates :email, uniqueness: { scope: :workspace_id, case_sensitive: false }, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates_presence_of     :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of       :password, within: Devise.password_length, allow_blank: true

  after_commit :create_wallet, on: :create

  before_validation :strip_phone_number, :append_country_code_to_phone_number, :capitalize_name
  
  scope :query, -> (keyword) { where('name ILIKE :keyword OR phone_number ILIKE :keyword OR email ILIKE :keyword', {keyword: "%#{keyword}%"}) }

  protected
    def email_required?
      false
    end

    def password_required?
      false
    end

  private
    def create_wallet
      Wallet.find_or_create_by(customer_id: self.id)
    end

    def strip_phone_number
      return unless self.phone_number.present?
      self.phone_number = self.phone_number.strip
    end

    def append_country_code_to_phone_number
      return unless self.phone_number.present?
      self.phone_number = "6#{self.phone_number}" if self.phone_number.start_with?('0')
      self.phone_number = "60#{self.phone_number}" if self.phone_number.start_with?('1')
    end

    def capitalize_name
      return unless self.name.present?
      self.name = self.name.titleize
    end
end
