class Customer < Account
  devise :validatable

  has_one :wallet, dependent: :nullify
  has_many :wallet_transactions, through: :wallet

  validates :name, presence: true
  validates :phone_number, uniqueness: true, presence: true
  validates :email, uniqueness: true, allow_blank: true

  after_commit :create_wallet, on: :create

  before_validation :strip_phone_number, :append_country_code_to_phone_number, :capitalize_name

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