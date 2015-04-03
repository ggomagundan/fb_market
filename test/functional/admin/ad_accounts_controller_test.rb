require 'test_helper'

class Admin::AdAccountsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => AdAccount.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    AdAccount.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    AdAccount.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to admin_ad_account_url(assigns(:ad_account))
  end

  def test_edit
    get :edit, :id => AdAccount.first
    assert_template 'edit'
  end

  def test_update_invalid
    AdAccount.any_instance.stubs(:valid?).returns(false)
    put :update, :id => AdAccount.first
    assert_template 'edit'
  end

  def test_update_valid
    AdAccount.any_instance.stubs(:valid?).returns(true)
    put :update, :id => AdAccount.first
    assert_redirected_to admin_ad_account_url(assigns(:ad_account))
  end

  def test_destroy
    ad_account = AdAccount.first
    delete :destroy, :id => ad_account
    assert_redirected_to admin_ad_accounts_url
    assert !AdAccount.exists?(ad_account.id)
  end
end
