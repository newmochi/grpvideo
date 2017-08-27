# coding: utf-8

class TopController < ApplicationController
  def index
  end  # def indexの終わり

  def sysope
  end

  def about
  end

  def not_found
    raise ActionController::RoutingError,
      "No route matches #{request.path.inspect}"
  end
end
