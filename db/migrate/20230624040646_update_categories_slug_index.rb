class UpdateCategoriesSlugIndex < ActiveRecord::Migration[7.0]
  def change
    add_index :categories, [:name, :workspace_id], unique: true
    remove_index :categories, :slug
    add_index :categories, [:slug, :workspace_id], unique: true, where: "slug IS NOT NULL AND slug !=''"
  end
end
