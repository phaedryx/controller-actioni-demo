class WidgetBlueprint < ApplicationBlueprint
  identifier :id

  view :index do
    fields :name, :material
  end

  view :update do
    fields :name, :material
  end

  view :show do
    fields :name, :material
  end
end
