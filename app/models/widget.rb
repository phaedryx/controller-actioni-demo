class Widget < ApplicationRecord
  VALID_MATERIALS = %w[wood metal plastic glass truffula]

  validates :name, presence: true
  validates :sku, presence: true
  validates :material, inclusion: { in: VALID_MATERIALS }
end
