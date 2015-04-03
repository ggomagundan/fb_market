# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  has_many :call_requests, :dependent => :destroy
  has_many :call_requests, :dependent => :nullify

  #authenticates_with_sorcery!

  validates_uniqueness_of :email, :message => "이미 사용중인 이메일 입니다.", :on => :create
  validates_presence_of :email, :message => "필수 입력 항목 입니다."
#  validates_presence_of :password, :on => :create
  #validates_confirmation_of :password, :message => "비밀번호가 일치하지 않습니다."
  #
  
  # 해야됨
  #validates :email, format: {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "잘못된 이메일 형식입니다."}

  after_create do |user|

    if user.access_token.blank?
      token = SecureRandom.urlsafe_base64
      append = user.id.to_s
      token = token.slice(0, token.length - append.length) + append
      user.update_attribute :access_token, token
    end

  end


  mount_uploader :picture, ImageUploader

  THUMBNAIL = {:picture => [150, 150]}
  ANDROID = {:picture => [800, 600]}
  IPHONE = {:picture => [800, 600]}


  def self.from_omniauth(auth)
    where(auth.slice(auth.provider, auth.id)).first_or_initialize.tap do |user|
      user.email = auth.info.email
      user.fb_uid = auth.uid
      user.username = auth.info.name
      user.oauth_token = auth.credentials.token
      #user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end

  def user_type
    USER_TYPE.key(self[:user_type])
  end

  def managing_departments(hospital_id)
    if self.user_type == :hospital_admin
      self.hospitals.find(hospital_id).departments
    elsif self.user_type == :department_admin
      self.departments(:hospital_id => hospital_id).joins(:user_hospital_departments => :user).where("users.user_type = ?", User::USER_TYPE[:department_admin])
    end
  end


  def health_feeds
    user_read_health_feed_ids = HealthFeed.joins(:user_read_health_feeds).where("user_read_health_feeds.user_id = ?", self.id).map{|news_feed| news_feed.id}
    health_feeds = HealthFeed.joins("left outer join user_know_hospitals on health_feeds.hospital_id = user_know_hospitals.hospital_id")
    if user_read_health_feed_ids.present?
      health_feeds = health_feeds.where("health_feeds.id not in (?)", user_read_health_feed_ids)
    end
    health_feeds = health_feeds.where("health_feeds.feed_type = ? or (health_feeds.feed_type = ? and user_know_hospitals.user_id = ?) ", 1, 2, self.id)
  end


  def new_grade
    if self.level == 1
      return {
        :title =>  LevelInfo.where(:level => 1).first.title,
        :gudie => LevelInfo.where(:level => 1).first.guide, 
        :level => 1,
        :image_url => LevelInfo.where(:level => 1).first.image.url,
        :thumbnail_url => LevelInfo.where(:level => 1).first.image.thumbnail.url,
        :background_url => LevelInfo.first.background.url,
        :android_background_url => LevelInfo.first.background.android.url
      }
    elsif self.level == 2
      return {
        :title =>  LevelInfo.where(:level => 2).first.title,
        :gudie => LevelInfo.where(:level => 2).first.guide, 
        :level => 2,
        :image_url => LevelInfo.where(:level => 2).first.image.url,
        :thumbnail_url => LevelInfo.where(:level => 2).first.image.thumbnail.url,
        :background_url => LevelInfo.first.background.url,
        :android_background_url => LevelInfo.first.background.android.url
      }
    elsif self.level == 3
      return {
        :title =>  LevelInfo.where(:level => 3).first.title,
        :gudie => LevelInfo.where(:level => 3).first.guide, 
        :level => 3,
        :image_url => LevelInfo.where(:level => 3).first.image.url,
        :thumbnail_url => LevelInfo.where(:level => 3).first.image.thumbnail.url,
        :background_url => LevelInfo.first.background.url,
        :android_background_url => LevelInfo.first.background.android.url
      }
    elsif self.level == 4
      return {
        :title =>  LevelInfo.where(:level => 4).first.title,
        :gudie => LevelInfo.where(:level => 4).first.guide, 
        :level => 4,
        :image_url => LevelInfo.where(:level => 4).first.image.url,
        :thumbnail_url => LevelInfo.where(:level => 4).first.image.thumbnail.url,
        :background_url => LevelInfo.first.background.url,
        :android_background_url => LevelInfo.first.background.android.url
      }
    elsif self.level == 5
      return {
        :title =>  LevelInfo.where(:level => 5).first.title,
        :gudie => LevelInfo.where(:level => 5).first.guide, 
        :level => 5,
        :image_url => LevelInfo.where(:level => 5).first.image.url,
        :thumbnail_url => LevelInfo.where(:level => 5).first.image.thumbnail.url,
        :background_url => LevelInfo.first.background.url,
        :android_background_url => LevelInfo.first.background.android.url
      }
    end
  end


  def grade
    if self.level == 1
      return {

        :title => "건강초딩", 
        :gudie => "아는병원만 등록해도 초딩졸업", 
        :level => 1,
        :image_url => "/grade/image/img_mypage_lev1.png",
        :thumbnail_url => "/grade/thumbnail/img_mypage_lev1_thumb.png"
        

      }
    elsif self.level == 2
      return {
        :title => "건강중딩", 
        :gudie => "병원팁만 작성해도 중딩졸업", 
        :level => 2,
        :image_url => "/grade/image/img_mypage_lev2.png",
        :thumbnail_url => "/grade/thumbnail/img_mypage_lev2_thumb.png"
      }
    elsif self.level == 3
      return {

        :title => "건강고딩", 
        :gudie => "상담과 이벤트신청으로 고딩졸업", 
        :level => 3,
        :image_url => "/grade/image/img_mypage_lev3.png",
        :thumbnail_url => "/grade/thumbnail/img_mypage_lev3_thumb.png"

      }
    elsif self.level == 4
      return {

        :title => "건강대딩", 
        :gudie => "병원예약으로 대딩졸업", 
        :level => 4,
        :image_url => "/grade/image/img_mypage_lev4.png",
        :thumbnail_url => "/grade/thumbnail/img_mypage_lev4_thumb.png"

      }
    elsif self.level == 5
      return {

        :title => "건강박사", 
        :gudie => "당신의 병원이 곧 최고의 병원", 
        :level => 5,
        :image_url => "/grade/image/img_mypage_lev5.png",
        :thumbnail_url => "/grade/thumbnail/img_mypage_lev5_thumb.png"

      }
    end
  end
  

  
  def level
    if self.health_point >= 0 && self.health_point < 200
      return 1
    elsif self.health_point >= 200 && self.health_point < 300
      return 2
    elsif self.health_point >= 300 && self.health_point < 500
      return 3
    elsif self.health_point >= 500
      user_count = User.count
      higher_user_count = User.where("users.health_point > ?", self.health_point).count
      if higher_user_count < user_count / 2
        return 5
      else
        return 4
      end
    end

  end


  def point_for_next_level
    if self.level == 1
      return 200
    elsif self.level == 2
      return 300
    elsif self.level == 3
      return 500
    elsif self.level == 4
      user_count = User.count
      if user_count % 2 == 0
        goal_point = User.reorder("users.health_point desc").offset(user_count/2).first.health_point
      else
        goal_point = User.reorder("users.health_point desc").offset(user_count/2 + 1).first.health_point
      end

      return (goal_point >= 500) ? goal_point : 500

    elsif self.level == 5
      return self.health_point
    end

  end


  def point_percentage
    ((self.health_point.to_f / self.point_for_next_level.to_f) * 100).round(0)
  end


  def facebook

    if @graph.present?
      return @graph
    else
      sns_connections = self.sns_connections.where(:provider => 1)
      if sns_connections.present?
        oauth_token = sns_connections.first.oauth_token
        @graph = Koala::Facebook::API.new(oauth_token)
        return @graph
      else
        return nil
      end
    end
  end

  def friends
    return User.where(:id => nil) if self.facebook.blank?
    begin
      uids = self.facebook.get_connections("me", "friends").map {|friend_object| friend_object["id"]}
    rescue Exception => e
      return super
    end
      friends = User.joins(:sns_connections).where("users.id != ? and sns_connections.provider = ? and (sns_connections.uid in (?))", self.id, 1, uids)
      self.friend_ids = friends.all.map {|friend|  friend.id}
      return friends
  end

  def age_concept
    if self.age.present?
      if age >= 100 
        first_number = self.age
        if I18n.locale == :ja
          "#{first_number}年生"
        else
          "#{first_number}년생"
        end
      else
        first_number = self.age / 10
        if I18n.locale == :ja
          "#{first_number}0代"
        else
          "#{first_number}0대"
        end
      end 
    else
      "?" 
    end 
  end


  def meta_themes
    if self.sex.present? && self.job.present? && self.age.present?
      MetaTheme.where("(meta_themes.sex = ? || meta_themes.sex is null || meta_themes.sex = 0) &&  
                       (meta_themes.job = ? || meta_themes.job is null || meta_themes.job = 0) &&
                       ((? between meta_themes.min_age and meta_themes.max_age) || meta_themes.max_age is null || meta_themes.min_age is null  || meta_themes.max_age = 0 || meta_themes.min_age = 0)
                      ", self.sex, self.job, self.age).reorder("(#{self.sex} = meta_themes.sex) + (#{self.job} = meta_themes.job) + (#{self.age} between meta_themes.min_age and meta_themes.max_age) desc")
    else
      MetaTheme.where("(meta_themes.sex is null or meta_themes.sex = 0) and (meta_themes.job is null or meta_themes.job = 0 )and (meta_themes.max_age is null or meta_themes.min_age is null or meta_themes.max_age = 0)")
    end
  end

  def last_know_hospital_date
    if self.user_know_hospitals.reorder("user_know_hospitals.updated_at desc").present?
      self.user_know_hospitals.reorder("user_know_hospitals.updated_at desc").first.updated_at_str
    else
      self.created_at_str
    end
  end

  def last_conversation_date
   if self.conversations.reorder("conversations.updated_at desc").present?
      self.conversations.reorder("conversations.updated_at desc").first.updated_at_str
   else
     self.created_at_str
   end
  end

  def last_request_date
   if self.call_requests.reorder("call_requests.updated_at desc").present?
     self.call_requests.reorder("call_requests.updated_at desc").first.updated_at_str
   else
     self.created_at_str
   end
  end

  
  def last_reservation_date
   if self.reservations.reorder("reservations.updated_at desc").present?
     self.reservations.reorder("reservations.updated_at desc").first.updated_at_str
   elsif self.bookings.reorder("bookings.updated_at desc").present?
     self.bookings.reorder("bookings.updated_at desc").first.updated_at_str
   else
     self.created_at_str
   end
  end  

  # uu = User.joins(:devices).where("devices.user_id = 32838").last
  # https://github.com/NicosKaralis/pushmeup
  def push_fire(title, msg)
    if Rails.env == "production"
#      GCM.host = 'https://android.googleapis.com/gcm/send'
#      GCM.format = :json
#      GCM.key = "AIzaSyBWx7Nh7iUJpTXVQlgRjYD89a8gMxQz5Cc"
#      push_msg = {:title =>title, :msg => msg}
#      push_list = []
   #   self.devices.each do  |device|
   #     if(device.device_type == 'AndroidDevice')
   #       push_list.push GCM::Notification.new(device.device_id, push_msg)
   #     end        
   #   end
   #   GCM.send_notifications(push_list)
gcm = GCM.new("AIzaSyBWx7Nh7iUJpTXVQlgRjYD89a8gMxQz5Cc")
      push_msg = {:data => {:title => title, :msg => msg}}
      push_list = []
      self.devices.each do |device|
        if(device.device_type == 'AndroidDevice')
          push_list.push device.device_id
        end
      end

        gcm.send_notification(push_list, push_msg)

    else
      puts "#{title} #{msg}"
    end
  end


  def self.push_fire(title, msg)
    device_ids = self.joins(:devices).where("devices.device_type = 'AndroidDevice'").select("devices.device_id").all.map {|user| user.device_id}.uniq
    if Rails.env == "production"
#      GCM.host = 'https://android.googleapis.com/gcm/send'
#      GCM.format = :json
#      GCM.key = "AIzaSyBWx7Nh7iUJpTXVQlgRjYD89a8gMxQz5Cc"
#      push_msg = {:title =>title, :msg => msg}
#      push_list = []
#      device_ids.each do  |device_id|
#        push_list.push GCM::Notification.new(device_id, push_msg)
#      end
#      GCM.send_notifications(push_list)
    gcm = GCM.new("AIzaSyBWx7Nh7iUJpTXVQlgRjYD89a8gMxQz5Cc")
      push_msg = {:data => {:title => title, :msg => msg}}
      push_list = []
        device_ids.each do  |device_id|
          push_list.push device_id
        end

        gcm.send_notification(push_list, push_msg)

    else
      puts "#{title} #{msg}"
    end
  end


  def self.admin_users
    User.where("user_type >= ? and user_type < ?", User::USER_TYPE[:admin_marketing_low], User::USER_TYPE[:admin_dev_low])
  end

  def arrange_ids
    self.arrange_hospitals.pluck(:arrange_hospital_id)
  end
end
