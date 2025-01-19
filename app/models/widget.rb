class Widget < ApplicationRecord
  VALID_MATERIALS = %w[wood metal plastic glass]

  validates :name, presence: true
  validates :material, inclusion: { in: VALID_MATERIALS }
end
