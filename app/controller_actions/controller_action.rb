require "dry/schema"

Dry::Schema.load_extensions(:json_schema)

class ControllerAction
  Error = Class.new(StandardError)
  MissingCallMethodError = Class.new(Error)
  MissingSchemaError     = Class.new(Error)
  InvalidStatusError     = Class.new(Error)

  class << self
    def params_schema(&)
      @schema = Dry::Schema.Params(&)
      @json_schema = Dry::Schema.JSON(&).json_schema
    end

    attr_reader :schema, :json_schema

    def call(params: nil, context: nil)
      instance = new

      raise MissingCallMethodError unless instance.respond_to?(:call)
      raise MissingSchemaError if schema.nil? && params.present?

      return response(instance.call(params:, context:)) if params.blank?

      params = standard_params(params)
      errors = schema.call(params).errors # rubocop:disable Rails/DeprecatedActiveModelErrorsMethods

      if errors.any?
        return error_response(
          status: :unprocessable_content,
          errors: errors.to_h,
          error_message: "Invalid parameters"
        )
      end

      response(instance.call(params:, context:))
    end

    def standard_params(params)
      params = params.to_unsafe_h if params.is_a?(ActionController::Parameters)
      params.to_h.symbolize_keys
    end

    def success?(result)
      code = Rack::Utils::SYMBOL_TO_STATUS_CODE[result[:status]]
      raise InvalidStatusError, "Invalid status code: #{result[:status]}" unless code

      code.between?(200, 299)
    end

    def default_meta
      {
        request_id: Current.request_id,
        timestamp: Time.current.iso8601
      }
    end

    def default_error_message(status)
      status.to_s.humanize.downcase
    end

    def error_response(errors:, status:, error_message: nil, meta: {})
      {
        json: {
          error_message: error_message || default_error_message(status),
          errors: errors,
          meta: default_meta.merge(meta)
        },
        status: status
      }
    end
    def success_response(resource:, status:, meta: {})
      {
        json: resource.merge(meta: default_meta.merge(meta)),
        status: status
      }
    end

    def response(result)
      success?(result) ? success_response(**result) : error_response(**result)
    end
  end
end
