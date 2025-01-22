module Widgets
  class UpdateAction < ControllerAction
    params_schema do
      required(:id).value(:integer)
      optional(:widget).hash do
        optional(:name).maybe(:string)
        optional(:description).maybe(:string)
        optional(:sku).maybe(:string)
        optional(:color).maybe(:string)
        optional(:material).maybe(:string)
      end
    end

    def call(params:, **)
      widget = Widget.find(params[:id])

      return { status: :not_found, errors: { id: [ "not found" ] } } unless widget
      return { status: :unprocessable_content, errors: widget.errors.to_hash } unless widget.update(params[:widget])

      resource = WidgetBlueprint.render_as_hash(widget, view: :update, root: :widget)

      { status: :ok, resource: resource }
    end
  end
end
