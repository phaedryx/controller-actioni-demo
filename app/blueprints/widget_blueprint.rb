class WidgetBlueprint < ApplicationBlueprint
  identifier :id

  view :base do
    fields :name, :description, :sku, :color, :material, :available
  end

  view :index do
    include_view :base
  end

  view :update do
    include_view :base
    fields :created_at, :updated_at
  end

  view :show do
    include_view :base
    fields :created_at, :updated_at
  end
end
