require "test_helper"

describe Widgets::CreateAction do
  it "returns a unprocessable_content error if the widget is not valid" do
    params = { widget: { name: nil } }
    actual = Widgets::CreateAction.new.call(params:)
    expected = {
      status: :unprocessable_content,
      errors: {
        widget: {
          name: [ "can't be blank" ],
          sku: [ "can't be blank" ],
          material: [ "is not included in the list" ]
        }
      }
    }

    _(actual).must_equal expected
  end

  it "returns a created status and the widget info if the widget is valid" do
    params = { widget: { name: "test", sku: "widget-1", material: "wood", color: "red", description: "test description" } }
    actual = Widgets::CreateAction.new.call(params:)
    expected = {
      status: :created,
      resource: {
        widget: {
          id: Widget.last.id,
          name: "test",
          sku: "widget-1",
          material: "wood",
          color: "red",
          description: "test description",
          available: nil
        }
      }
    }

    _(actual).must_equal expected
  end
end
