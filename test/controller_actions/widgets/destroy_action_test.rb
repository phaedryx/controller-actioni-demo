require "test_helper"

describe Widgets::DestroyAction do
  it "returns a not_found status if the widget is not found" do
    actual = Widgets::DestroyAction.new.call(params: { id: -1 })
    expected = { status: :not_found, errors: { id: [ "not found" ] } }

    _(actual).must_equal expected
  end

  it "returns a destroyed status and the widget info" do
    widget = Widget.create!(name: "test", sku: "widget-1", material: "wood")
    actual = Widgets::DestroyAction.new.call(params: { id: widget.id })
    expected = { status: :ok, resource: { widget: { id: widget.id } } }

    _(actual).must_equal expected
  end
end
