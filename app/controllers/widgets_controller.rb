class WidgetsController < ApplicationController
  def index
    render Widgets::IndexAction.call
  end

  def create
    render Widgets::CreateAction.call(params:)
  end

  def show
    render Widgets::ShowAction.call(params:)
  end

  def update
    render Widgets::UpdateAction.call(params:)
  end

  def destroy
    render Widgets::DestroyAction.call(params:)
  end
end
