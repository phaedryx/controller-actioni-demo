module Widgets
  class DestroyAction < ControllerAction
    params_schema do
      required(:id).filled(:integer)
    end

    def call(params:, **)
      widget = Widget.find_by(id: params[:id])

      return { status: :not_found, errors: { id: [ "not found" ] } } unless widget

      widget.destroy

      resource = WidgetBlueprint.render_as_hash(widget, view: :destroy, root: :widget)

      { status: :ok, resource: resource }
    end
  end
end
