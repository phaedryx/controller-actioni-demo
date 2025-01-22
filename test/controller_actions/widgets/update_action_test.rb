require "test_helper"

describe Widgets::UpdateAction do
  it "returns a not_found status if the widget is not found" do
    actual = Widgets::UpdateAction.new.call(params: { id: -1 })
    expected = { status: :not_found, errors: { id: [ "not found" ] } }

    _(actual).must_equal expected
  end

  it "returns an unprocessable_content status if the widget is not valid" do
    widget = Widget.create!(name: "test", sku: "widget-1", material: "wood")
    actual = Widgets::UpdateAction.new.call(params: { id: widget.id, widget: { name: nil, material: "invalid" } })
    expected = {
      status: :unprocessable_content,
      errors: {
        name: [ "can't be blank" ],
        material: [ "is not included in the list" ]
      }
    }

    _(actual).must_equal expected
  end

  it "returns an ok status and the widget info if the widget is valid" do
    widget = Widget.create!(name: "test", sku: "widget-1", material: "wood")
    actual = Widgets::UpdateAction.new.call(
      params: {
        id: widget.id,
        widget: {
          name: "updated",
          sku: "widget-2",
          material: "metal",
          color: "red",
          description: "test description"
        }
      }
    )
    expected = {
      status: :ok,
      resource: {
        widget: {
          id: widget.id,
          name: "updated",
          sku: "widget-2",
          material: "metal",
          color: "red",
          description: "test description",
          available: nil,
          updated_at: widget.updated_at.iso8601
        }
      }
    }

    _(actual).must_equal expected
  end
end
