module Widgets
  class ShowAction < ControllerAction
    params_schema do
      required(:id) { (int? | str?) & filled? }
    end

    def call(params:, **)
      widget = Widget.find_by(id: params[:id])

      return { status: :not_found, errors: { id: [ "not found" ] } } unless widget

      { status: :ok, resource: WidgetBlueprint.render_as_hash(widget, view: :show, root: :widget) }
    end
  end
end
