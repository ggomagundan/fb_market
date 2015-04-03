# -*- encoding : utf-8 -*-
class Event < ActiveRecord::Base

  translates :title, :header , :desc, :original_price, :discounted_price, :deny_message, :client_title, :client_header, :client_desc, :client_original_price, :client_discounted_price, :apply_text
  belongs_to :hospital

  has_many :event_infos
  has_many :call_requests
  has_many :theme_hospitals
  has_many :event_event_categories
  has_many :event_categories, :through => :event_event_categories
  has_many :admin_histories, :as => :content
  has_many :coocha_event

  has_many :client_event_event_categories, foreign_key: :event_id
  has_many :client_event_categories, :through => :client_event_event_categories, source: :event_category

  has_one :featuring, :as => :content, :dependent => :destroy

  belongs_to :hospital

  accepts_nested_attributes_for :event_infos, allow_destroy: true
  default_scope ->{order("event_type desc, events.rank_score desc").order("events.random_rank_score").joins(:hospital).select("events.*, hospitals.name as hospital_name, hospitals.addr as hospital_addr, hospitals.latitude as hospital_latitude, hospitals.longitude as hospital_longitude")}

  scope :korean_searchable, ->{ where("events.locale = 'ko'") }
  scope :japan_searchable, ->{ where("events.locale = 'ja'") }


  ANDROID = {:image => [800, 355], :square_image => [800, 800]}
  IPHONE = {:image => [800, 355], :square_image => [800, 800]}
  THUMBNAIL = {:image => [150, 150], :square_image => [150, 150]}

  mount_uploader :image, ImageUploader
  mount_uploader :square_image, ImageUploader
  mount_uploader :client_image, ImageUploader
  mount_uploader :client_square_image, ImageUploader

  #after_save :enqueue

  scope :ing, ->{ where("(? between events.start_on and events.end_on) or events.is_temporary = true", Date.today).where("events.searchable = true ")}

  after_save do |event|
     #if event.featuring.present?
     #  event.featuring.update_attribute :is_visible, event.is_ing?
     #else
     #  Featuring.create :content => event, :hospital_id => event.hospital_id, :is_visible => event.is_ing?
     #end

     if event.is_ing? == false
       ThemeHospital.where(:randing_type => "Event").where(:randing_id => event.id).update_all :randing_method => 0, :randing_type => nil, :randing_id => nil
     end

  end

#  after_save :enqueue

  before_create do |event|
    event.is_migration = 1
  end
  def self.only_magic_event
    ids = []
    EventEventCategory.where(event_category_id: 32).each do |ec|
      if ec.event.present? && ec.event.event_categories.count == 1

        ids.push(ec.event_id)

      end
    end
    ids
  end

  after_destroy do |event|
    ThemeHospital.where(:randing_type => "Event").where(:randing_id => event.id).update_all :randing_method => 0, :randing_type => nil, :randing_id => nil

  end

  def self.searchable
    self.ing
  end


  def self.visible_count
    self.ing.count("events.id")
  end

  def self.view_count
    self.view_count + self.fake_view_count
  end

  def joined_hospital
    @hospital ||= Hospital.new :name => self.hospital_name, :addr => self.hospital_addr, :latitude => self.hospital_latitude, :longitude => self.hospital_longitude
  end

  def is_hot
    self.view_count > 50
  end

  def is_new
    if(self.start_on.present? && (self.start_on > Date.today - 7)) or (self.is_temporary && (self.created_at.to_date > Date.today - 7))
      return true
    else
      return false
    end
  end

  def is_approaching_deadline
    self.end_on.present? && (self.end_on < (Date.today + 7)) && self.is_temporary != true
  end

  def is_ing?
    return true if is_temporary == true && searchable == true
    return false if is_temporary == true && searchable == false
    return false if start_on.blank? || end_on.blank?
    self.start_on <= Date.today && self.end_on >= Date.today && self.searchable
  end

  def period
    if self.is_temporary == false && self.start_on.present? && self.end_on.present?
      "#{self.start_on.strftime("%Y.%m.%d")} ~ #{self.end_on.strftime("%Y.%m.%d")}"
    else
      return ""
    end
  end


  def url
    if self.is_web_view == true  && (self.web_view_url != nil && self.web_view_url != '')
      return self.web_view_url
    elsif self.is_web_view == true
      return "http://neo.goodoc.co.kr/events"
    else
      return ""
    end

  end  

  def self.move_rank(rank, rank1)

    if rank.to_i > rank1.to_i
      Event.where("rank_score <  ? and rank_score >= ?", rank, rank1).each do |event|
        event.update_attributes(rank_score: event.rank_score + 1)
      end
    else
      Event.where("rank_score <  ? and rank_score >= ?", rank1, rank).each do |event|
        event.update_attributes(rank_score: event.rank_score + 1)
      end
    end

  end

  EVENT_STAUS_STR = [ 
    "공백",
    "검수 중",
    "반려",
    "라이브"
  ]

  def event_status_str

    if event_status == 1
      "검수중"
    elsif event_status == 2
      "반려"
    else
      if searchable
        "라이브 중"
      else
        "비노출 중"
      end
    end
  end

  def admin_info_to_client_info
    self.update_attributes(client_searchable: searchable, client_title: title, client_is_temporary: is_temporary, client_start_on: start_on, client_end_on: end_on, client_image: image, client_header: header, client_desc: desc, \
                             client_is_numerical_original_price: is_numerical_original_price, client_is_numerical_discounted_price: is_numerical_discounted_price, client_numerical_original_price: numerical_original_price, client_numerical_discounted_price: numerical_discounted_price, \
                             client_original_price: original_price, client_discounted_price: discounted_price, client_is_web_view: is_web_view, client_web_view_url: web_view_url, client_is_real_web_view: is_real_web_view, client_square_image: square_image, event_status: 3, deny_message: nil)
    self.client_event_category_ids = self.event_category_ids
    self.save
    self.event_infos.where(is_admin_info: 1).each do |info|
      info.update_attributes(client_image: info.image, is_client_info: 1, client_is_destroy: 0 )
    end

  end

  def client_info_to_admin_info
    self.update_attributes(searchable: client_searchable, title: client_title, is_temporary: client_is_temporary, start_on: client_start_on, end_on: client_end_on, image: client_image, header: client_header, desc: client_desc, \
                             is_numerical_original_price: client_is_numerical_original_price, is_numerical_discounted_price: client_is_numerical_discounted_price, numerical_original_price: client_numerical_original_price, numerical_discounted_price: client_numerical_discounted_price, \
                             original_price: client_original_price, discounted_price: client_discounted_price, is_web_view: client_is_web_view, web_view_url: client_web_view_url, is_real_web_view: client_is_real_web_view, square_image: client_square_image, event_status: 3, deny_message: nil)
    self.event_category_ids = self.client_event_category_ids
    self.save
    self.event_infos.where(is_client_info: 1, client_is_destroy: 0).each do |info|
      info.update_attributes(image: info.client_image, is_admin_info: 1)
    end

    self.event_infos.where(client_is_destroy: 1).destroy_all

  end


end
