class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_current_attributes
  skip_before_action :verify_authenticity_token

  def set_current_attributes
    Current.request_id = request.request_id
  end
end
