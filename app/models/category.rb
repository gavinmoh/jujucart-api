class Category < ApplicationRecord
  has_many :products, dependent: :nullify

  validates :name, presence: true 

  mount_base64_uploader :photo, PhotoUploader

  scope :query, ->(keyword) { where('name ILIKE ?', "%#{keyword}%") }

  after_commit :update_slug, if: -> { (not self.slug.present?) and saved_change_to_attribute?(:name) }

  has_paper_trail

  private
    def update_slug
      new_slug ||= self.name.parameterize
      self.update(slug: new_slug)
    rescue ActiveRecord::RecordNotUnique
      new_slug = new_slug + '-' + SecureRandom.hex(3)
      retry
    end
end
