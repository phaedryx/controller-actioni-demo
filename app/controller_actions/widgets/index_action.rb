module Widgets
  class IndexAction < ControllerAction
    def call(**)
      widgets = Widget.all

      resource = WidgetBlueprint.render_as_hash(widgets, view: :index, root: :widgets)

      { status: :ok, resource: resource }
    end
  end
end
