class Category < ApplicationRecord
  has_many :products, dependent: :nullify

  validates :name, presence: true 

  mount_base64_uploader :photo, PhotoUploader

  scope :query, ->(keyword) { where('name ILIKE ?', "%#{keyword}%") }
  scope :bestseller, -> (from_date: Date.current.beginning_of_month, to_date: Date.current.end_of_month, limit: 10, store_id: nil, metric: 'sold_quantity') {
    categories =
      joins(products: { line_items: { order: :store } })
        .where(orders: { completed_at: from_date.beginning_of_day..to_date.end_of_day })
        .group('categories.id')
        .limit(limit)

    categories = categories.where(orders: { store_id: store_id }) if store_id

    if metric == 'sold_quantity'
      categories = categories.order(LineItem.arel_table[:quantity].sum.desc)
    else
      categories = categories.order((LineItem.arel_table[:quantity] * LineItem.arel_table[:unit_price_cents]).sum.desc)
    end

    categories
  }

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
