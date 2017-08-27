class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
#  protect_from_forgery with: :exception
  protect_from_forgery with: :null_session

# 以下7行はベーシック認証
  before_filter :basic
  private
  def basic
    authenticate_or_request_with_http_basic do |user, pass|
      user == 'superdelux' && pass == 'isasan1monbunkakai'
    end
  end
end

