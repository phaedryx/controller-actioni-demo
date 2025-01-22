class Widgets::CreateAction < ControllerAction
  params_schema do
    required(:widget).hash do
      required(:name).filled(:string)
      required(:sku).filled(:string)
      required(:material).filled(:string)
      optional(:description).maybe(:string)
      optional(:color).maybe(:string)
    end
  end

  def call(params:, **)
    widget = Widget.new(params[:widget])

    return { status: :unprocessable_content, errors: { widget: widget.errors.to_hash } } unless widget.save

    resource = WidgetBlueprint.render_as_hash(widget, view: :create, root: :widget)

    { status: :created, resource: resource }
  end
end
