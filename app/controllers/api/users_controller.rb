class Api::UsersController < Api::ApplicationController
  def index
    @users = User.all
  end

  def show
    @graph = Koala::Facebook::API.new(User.first.oauth_token)
   profile = @graph.get_object("me")
   binding.pry
  end

  def new

      @graph = Koala::Facebook::API.new(params[:oauth_token])
      binding.pry
      profile = @graph.get_object("me")
      if profile.present?
        uid = profile["id"]
        email = profile["email"]
        gender = profile["gender"]
        name = profile["name"]
        fb_token = params[:oauth_token]
        user = User.new(email: email, username: name, fb_token: fb_token, fb_uid: uid)

        if User.where(:uid => uid).present?
          @jsonResult.message = "로그인이 완료되었습니다,"
          @jsonResult.object  = User.where(:uid => uid).first
        else
          user.save
          @jsonResult.message = "로그인이 완료되었습니다,"
          @jsonResult.object  = User.where(:uid => uid).first

        end
      end

  end

  def create
   @graph = Koala::Facebook::API.new(params[:oauth_token])
      profile = @graph.get_object("me")
      if profile.present?
        uid = profile["id"]
        email = profile["email"]
        name = profile["name"]
        oauth_token = params[:oauth_token]
        user = User.new(email: email, username: name, oauth_token: oauth_token, fb_uid: uid)


        if User.where(fb_uid: uid).present?
          @jsonResult.message = "로그인이 완료되었습니다,"
          @jsonResult.object  = User.where(fb_uid: uid).first
        else
          user.save
          @jsonResult.message = "로그인이 완료되었습니다,"
          @jsonResult.object  = User.where(fb_uid: uid).first

        end
      end


  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to [:api, @user], :notice  => "Successfully updated user."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to api_users_url, :notice => "Successfully destroyed user."
  end
end
