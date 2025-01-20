require "test_helper"

describe Widgets::ShowAction do
  it "returns a not_found error if there is no widget matching the id" do
    params = { id: -1 }
    actual = Widgets::ShowAction.new.call(params:)
    expected = { status: :not_found, errors: { id: [ "not found" ] } }

    _(actual).must_equal expected
  end

  it "returns a widget hash if there is a widget matching the id" do
    widget = Widget.create!(
      name: "test",
      description: "test description",
      sku: "widget-1",
      available: true,
      color: "brown",
      material: "wood"
    )
    params = { id: widget.id }
    actual = Widgets::ShowAction.new.call(params:)
    expected = {
      status: :ok,
      resource: {
        widget: {
          id: widget.id,
          name: "test",
          sku: "widget-1",
          description: "test description",
          material: "wood",
          available: true,
          color: "brown",
          created_at: widget.created_at.iso8601,
          updated_at: widget.updated_at.iso8601
        }
      }
    }

    _(actual).must_equal expected
  end
end
