require "test_helper"

describe ControllerAction do
  make_my_diffs_pretty!

  before do
    Current.request_id = "1234567890"
    Timecop.freeze(Time.current)
  end

  after do
    Timecop.return
  end

  it "checks true" do
    _(true).must_equal true
  end

  describe ".params_schema" do
    it "sets the schema and json_schema" do
      schema_action = Class.new(ControllerAction) do
        params_schema do
          required(:user).hash do
            required(:first_name).filled(:string)
            optional(:last_name).maybe(:string)
          end
        end
      end

      _(schema_action.schema).must_be_instance_of(Dry::Schema::Params)
      _(schema_action.schema.call(user: { first_name: "John" }).errors).must_be_empty
      _(schema_action.schema.call(user: { first_name: "John", last_name: "Doe" }).errors).must_be_empty
      _(schema_action.schema.call(user: { first_name: "John", last_name: nil }).errors).must_be_empty
      _(schema_action.schema.call(user: { first_name: "John", last_name: "Doe" }).errors).must_be_empty
      _(schema_action.schema.call(user: { first_name: "", last_name: "Doe" }).errors.to_hash).must_equal({
        user: {
          first_name: [ "must be filled" ]
        }
      })
      _(schema_action.schema.call(user: { first_name: "John", last_name: nil, extra: "extra" }).errors.to_hash).must_equal({})
      _(schema_action.json_schema).must_equal({
        "$schema": "http://json-schema.org/draft-06/schema#",
        type: "object",
        properties: {
          user: {
            type: "object",
            properties: {
              first_name: { type: "string", minLength: 1 },
              last_name: { type: [ "null", "string" ] }
            },
            required: [ "first_name" ]
          }
        },
        required: [ "user" ]
      })
    end
  end

  describe ".call" do
    it "raises a MissingCallMethodError when the inheriting class doesn't define #call" do
      _(proc { Class.new(ControllerAction).call }).must_raise ControllerAction::MissingCallMethodError
    end

    it "raises a MissingSchemaError when the params are given but the schema is not set" do
      missing_schema_action = Class.new(ControllerAction) do
        def call(*)
          { status: :ok }
        end
      end
      _(proc { missing_schema_action.call(params: { foo: "bar" }) }).must_raise ControllerAction::MissingSchemaError
    end

    it "is possible to only pass context" do
      context_action = Class.new(ControllerAction) do
        def call(context:, **)
          { status: :ok, resource: context }
        end
      end

      actual = context_action.call(context: { foo: "bar" })
      expected = {
        json: { foo: "bar" },
        status: :ok
      }

      _(actual[:json][:foo]).must_equal(expected[:json][:foo])
      _(actual[:status]).must_equal(expected[:status])
    end

    it "allows all params to be optional" do
      health_check_action = Class.new(ControllerAction) do
        def call(**)
          { status: :ok, resource: { health: "ok" } }
        end
      end

      actual = health_check_action.call

      expected = {
        json: { health: "ok" },
        status: :ok
      }
      _(actual[:json][:health]).must_equal(expected[:json][:health])
      _(actual[:status]).must_equal(expected[:status])
    end

    it "returns an error response when the params are invalid" do
      invalid_params_action = Class.new(ControllerAction) do
        params_schema do
          required(:widget).hash do
            required(:name).filled(:string)
            required(:description).filled(:string)
            required(:price).filled(:integer)
          end
        end

        def call(params:, **)
          { status: :ok }
        end
      end
      actual = invalid_params_action.call(params: {
        widget: {
          name: "",
          description: "",
          price: ""
        }
      })

      expected = {
        json: {
          error_message: "Invalid parameters",
          errors: {
            widget: {
              name: [ "must be filled" ],
              description: [ "must be filled" ],
              price: [ "must be filled" ]
            }
          },
          meta: {
            request_id: Current.request_id,
            timestamp: Time.current.iso8601
          }
        },
        status: :unprocessable_content
      }
      _(actual).must_equal(expected)
    end

    it "returns a success response when the params are valid" do
      valid_params_action = Class.new(ControllerAction) do
        params_schema do
          required(:user).hash do
            required(:first_name).filled(:string)
            required(:last_name).filled(:string)
          end
        end

        def call(params:, **)
          { status: :ok, resource: params }
        end
      end

      actual = valid_params_action.call(params: { user: { first_name: "John", last_name: "Doe" } })
      expected = {
        json: {
          user: {
            first_name: "John",
            last_name: "Doe"
          },
          meta: {
            request_id: Current.request_id,
            timestamp: Time.current.iso8601
          }
        },
        status: :ok
      }
      _(actual).must_equal(expected)
      _(valid_params_action.json_schema).must_equal({
        "$schema": "http://json-schema.org/draft-06/schema#",
        type: "object",
        properties: {
          user: {
            type: "object",
            properties: {
              first_name: { type: "string", minLength: 1 },
              last_name: { type: "string", minLength: 1 }
            },
            required: [ "first_name", "last_name" ]
          }
        },
        required: [ "user" ]
      })
    end
  end

  describe ".success?" do
    it "returns true when the response is a success" do
      _(ControllerAction.success?({ status: :ok })).must_equal(true)
      _(ControllerAction.success?({ status: :created })).must_equal(true)
      _(ControllerAction.success?({ status: :no_content })).must_equal(true)
    end

    it "returns false when the response is not a success" do
      _(ControllerAction.success?({ status: :unprocessable_content })).must_equal(false)
      _(ControllerAction.success?({ status: :not_found })).must_equal(false)
    end

    it "raises an InvalidStatusError when the status code is not a valid HTTP status code" do
      _(proc { ControllerAction.success?({ status: :non_http_status }) }).must_raise ControllerAction::InvalidStatusError
    end
  end

  describe ".default_meta" do
    it "returns a hash with the request_id and timestamp" do
      Current.request_id = "1234567890"
      iso_format = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/

      _(ControllerAction.default_meta[:request_id]).must_equal(Current.request_id)
      _(ControllerAction.default_meta[:timestamp]).must_match(iso_format)
    end
  end

  describe ".default_error_message" do
    it "returns a default error message" do
      _(ControllerAction.default_error_message(:not_found)).must_equal("not found")
      _(ControllerAction.default_error_message(:unprocessable_content)).must_equal("unprocessable content")
    end
  end

  describe ".error_response" do
    it "returns a hash with the error message, errors, and meta" do
      widget = Widget.new(name: nil, sku: nil, material: "none")
      widget.valid?

      actual = ControllerAction.error_response(
        errors: widget.errors.to_hash,
        status: :unprocessable_content,
        error_message: "custom error message",
        meta: { bonus: "additional meta data" }
      )
      expected = {
        json: {
          error_message: "custom error message",
          errors: {
            name: [ "can't be blank" ],
            sku: [ "can't be blank" ],
            material: [ "is not included in the list" ]
          },
          meta: {
            bonus: "additional meta data",
            request_id: Current.request_id,
            timestamp: Time.current.iso8601
          }
        },
        status: :unprocessable_content
      }

      _(actual).must_equal(expected)
    end
  end

  describe ".success_response" do
    it "returns a hash with the resource and meta" do
      actual = ControllerAction.success_response(
        resource: { foo: "bar" },
        status: :ok,
        meta: { pagination: { total: 100, page: 1, per_page: 10 } }
      )
      expected = {
        json: {
          foo: "bar",
          meta: {
            pagination: { total: 100, page: 1, per_page: 10 },
            request_id: Current.request_id,
            timestamp: Time.current.iso8601
          }
        },
        status: :ok
      }
      _(actual).must_equal(expected)
    end
  end
end
