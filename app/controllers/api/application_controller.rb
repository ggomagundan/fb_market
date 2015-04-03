# -*- encoding : utf-8 -*-
class Api::ApplicationController < ApplicationController
  before_filter :create_json_object
  skip_before_filter  :verify_authenticity_token
  #after_filter :print_error

  helper ImageAddress

  rescue_from "Exception" do |e|
    @jsonResult.message = @error_message
    @jsonResult.status = false

    if Rails.env == "production" && params[:device] != 2
      ErrorMailer.error_mail(e, request.url, params).deliver!
    else
      puts e.backtrace
      raise 
    end
  end

  def create_json_object
    @jsonResult = JsonResult.new
    @jsonResult.code = "0000"
    @jsonResult.status = true
  end

  def authenticate_user  
    if params[:token].present?
      @current_user = User.find_by_access_token(params[:token])
    end

    if params[:is_import].present?
      @current_user =  User.find(KAI_ID)
    end

    if @current_user.nil? 
      @jsonResult = JsonResult.new
      @jsonResult.status = false
      @jsonResult.message = "로그인이 필요한 기능입니다.\n로그인이나 회원가입 후 이용해 주세요."
      render json: @jsonResult
    end
  end

  def flexiable_authenticate_user  
    if params[:token].present?
      @current_user = User.find_by_access_token(params[:token])
    end
  end


  def current_user
    @current_user
  end

  def exists?(file)
    begin
      uri = URI.parse(URI.escape(URI.unescape(file)))

      response = nil

      Net::HTTP.start(uri.host, uri.port) {|http|
        response = http.head(uri.path)
      }

      # .. response.content_type == "audio/mpeg"
      response.code == "200"

    rescue
      false
    end
  end
end

