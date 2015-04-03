class SessionsController < ApplicationController
  def index
    @sessions = Session.all
  end

  def show
    @session = Session.find(params[:id])
  end

  def new
    binding.pry
    user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to root_url
  end

  def create
    user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to root_url
  end

  def edit
    @session = Session.find(params[:id])
  end

  def update
    @session = Session.find(params[:id])
    if @session.update_attributes(params[:session])
      redirect_to @session, :notice  => "Successfully updated session."
    else
      render :action => 'edit'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end
end
