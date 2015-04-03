class Admin::AdAccountsController < ApplicationController
  def index
    @ad_accounts = AdAccount.all
  end

  def show
    @ad_account = AdAccount.find(params[:id])
  end

  def new
    @ad_account = AdAccount.new
  end

  def create
    @ad_account = AdAccount.new(params[:ad_account])
    if @ad_account.save
      redirect_to [:admin, @ad_account], :notice => "Successfully created ad account."
    else
      render :action => 'new'
    end
  end

  def edit
    @ad_account = AdAccount.find(params[:id])
  end

  def update
    @ad_account = AdAccount.find(params[:id])
    if @ad_account.update_attributes(params[:ad_account])
      redirect_to [:admin, @ad_account], :notice  => "Successfully updated ad account."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @ad_account = AdAccount.find(params[:id])
    @ad_account.destroy
    redirect_to admin_ad_accounts_url, :notice => "Successfully destroyed ad account."
  end
end
