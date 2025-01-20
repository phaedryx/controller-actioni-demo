class WidgetsController < ApplicationController
  def show
    render Widgets::ShowAction.call(params:)
  end
end
