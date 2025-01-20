Blueprinter.configure do |config|
  config.datetime_format = ->(datetime) { datetime.respond_to?(:iso8601) ? datetime.iso8601 : datetime.to_s }
end
