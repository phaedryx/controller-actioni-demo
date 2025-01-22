class WidgetsController < ApplicationController
  def create
    render Widgets::CreateAction.call(params:)
  end

  def show
    render Widgets::ShowAction.call(params:)
  end
end
