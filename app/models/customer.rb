class Customer < Account
  devise :recoverable, request_keys: [:workspace_id]

  belongs_to :workspace

  has_one :wallet, dependent: :nullify
  has_many :wallet_transactions, through: :wallet

  validates :name, presence: true
  validates :phone_number, uniqueness: { scope: :workspace_id }, presence: true

  # this block below is to replace devise :validatable
  # which doesn't work for uninqueness validation with scope
  validates :email, uniqueness: { scope: :workspace_id, case_sensitive: false }, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: { if: :password_required? }
  validates :password, confirmation: { if: :password_required? }
  validates :password, length: { within: Devise.password_length, allow_blank: true }

  before_validation :strip_phone_number, :append_country_code_to_phone_number, :capitalize_name
  after_commit :create_wallet, on: :create

  scope :query, ->(keyword) { where('name ILIKE :keyword OR phone_number ILIKE :keyword OR email ILIKE :keyword', { keyword: "%#{keyword}%" }) }

  def self.find_for_database_authentication(warden_conditions)
    where(email: warden_conditions[:email], workspace_id: warden_conditions[:workspace_id]).first
  end

  def reset_password_link(token)
    "#{Current.request_host}/user/reset_password?token=#{token}"
  end

  protected

    def email_required?
      false
    end

    def password_required?
      false
    end

  private

    def create_wallet
      Wallet.find_or_create_by(customer_id: id, workspace_id: workspace_id)
    end

    def strip_phone_number
      return unless phone_number.present?

      self.phone_number = phone_number.strip
    end

    def append_country_code_to_phone_number
      return unless phone_number.present?

      self.phone_number = "6#{phone_number}" if phone_number.start_with?('0')
      self.phone_number = "60#{phone_number}" if phone_number.start_with?('1')
    end

    def capitalize_name
      return unless name.present?

      self.name = name.titleize
    end
end
