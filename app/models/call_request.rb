# -*- encoding : utf-8 -*-
class CallRequest < ActiveRecord::Base
  belongs_to :hospital
  belongs_to :event, :counter_cache => true
  belongs_to :user, :counter_cache => true
  belongs_to :message

  has_many :event_apply_images
  has_many :admin_histories, :as => :content



  # validate
  # validates_presence_of :name, :phone, :message => "이름과 휴대전화번호는 필수입력 항목입니다."
  # validates_acceptance_of :privacy_agree, :message => "개인정보 취급방침에 동의를 하셔야됩니다.", :on => :create


  require "net/http"
  require "rexml/document"
  require "builder"

  STATUS = [
    {:title => "미확인", :guide => "병원에서 확인하지 않은 상태입니다."},
    {:title => "미완료", :guide => "병원에서 확인은 하였으나, 신청이 완료되지 않은 상태입니다."},
    {:title => "완료", :guide => "신청이 완료된 상태입니다."},
    {:title => "취소", :guide => "신청이 취소된 상태입니다."}
  ]


  CURRENT_STATUS = [
    "예약",
    "상담",
    "진료",
    "수납"
  ]



  default_scope ->{joins(:event, :hospital).select("call_requests.*, events.title as event_title, events.end_on as event_end_on, events.discounted_price as event_discounted_price, events.is_numerical_discounted_price as event_is_numerical_discounted_price, events.numerical_discounted_price as event_numerical_discounted_price, hospitals.name as hospital_name, hospitals.addr as hospital_addr").reorder("call_requests.id desc")}

  before_create do |call_request|
    if call_request.hospital_id.blank?
      call_request.hospital_id = call_request.event.hospital_id
    end
    if call_request.user.present?
      #conversation = Conversation.active.find_or_create_by_user_id_and_hospital_id call_request.user_id, call_request.hospital_id
      #message = conversation.messages.create :sender_id => call_request.user_id, :sender_type => "User", :message_type => "CallRequest", :created_at => call_request.created_at, :content_id => call_request.id
      #call_request.message_id = message.id
    end

    if call_request.event_cost.present? && call_request.event_cost > 0
      current_price = call_request.hospital.current_payment_price
      event_cost = call_request.event.event_cost
      Payment.create(hospital_id: call_request.hospital_id, payment_type: 3, price: event_cost, memo: "#{call_request.user_name}, #{call_request.event.title} 신청")

    #  if current_price <= event_cost
    #    call_request.event.update_attributes(searchable: false)
    #  end
    end



  end

  before_destroy do |call_request|
    call_request.message.try("destroy")
    call_request.delete_xml_to_esk
  end


  after_create do |call_request|
#    if call_request.user.present?
#      SMS.fire_for_hospital(call_request.hospital, "#{call_request.user.username}님이 #{call_request.event.title} 이벤트에 참가하셨습니다.")
#      UserNewsFeed.create :user_id => call_request.user_id, :hospital_id => call_request.hospital_id,
#                          :content_type => "CallRequest", :content_id => call_request.id,
    #                          :title => "병원이벤트 신청", :message => "#{call_request.hospital.name}의 '#{call_request.event.title}' #{I18n.t("model.user_news_feed.create_call_request")}",
#                          :health_point => 5, :late_activity => true, :created_at => call_request.created_at

#      if call_request.user.phone.present? && call_request.user.phone.length > 8
#        bitly = Shortly::Clients::Bitly
#        @short_url =  bitly.shorten("http://neo.goodoc.co.kr/hospitals/#{call_request.hospital.id}", {:apiKey => 'R_f8f64e38ff3fcafc3e40f32db16269c4', :login => 'kaipark'})

#        @hos_num = call_request.hospital.phone
#        if @hos_num == '' || @hos_num == ' '
#          @hos_num = nil
#        end

#        @user_msg = "#{call_request.user.username} 회원님, \"#{call_request.event.title.truncate(20, separator: ' ')}\" 이벤트를 신청해주셔서 감사합니다.\n"
#        if @hos_num.present?
#          @user_msg = @user_msg + "#{call_request.hospital.name}에서 #{@hos_num} 번호로 안내 전화 드리겠습니다.\n"
#        else
#          @user_msg = @user_msg + "#{call_request.hospital.name}에서 안내 전화 드리겠습니다.\n"
#        end
#        @user_msg = @user_msg + "(병원 정보: #{@short_url.url} )\n전화 꼭 받아주세요.^^"


#       @user_msg = @user_msg + "\n\n 150만 국민 병원앱 굿닥, 아직도 안받으셨어요? 굿닥은 앱으로 해야 더 편해요
#       앱 다운로드 받기-> https://play.google.com/store/apps/details?id=com.ksncho.hospitalinfo&hl=ko"
      
#       MMS.fire_to_user(call_request.user.phone, @hos_num,@user_msg) 
#      end

#    else








=begin
      url = "http://was.smartcrm.kr/smartcrm/webservice/xml_callrequest.asp"
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      begin
        req = http.request_post url,  {chksum: "23f07fae59a1a1eb160b145521269207"}.to_params
        if req.body.present?

    self.to_xmls
=end



    #LogApi.post_to_url "/api/call_requests/send_sms.json", call_request.attributes.to_query + "&event_title=#{call_request.event.title}&hospital_phone=#{call_request.hospital.phone}&hospital_name=#{call_request.hospital.name}&neo_id=#{OldHospital.where(hira_hospital_id: call_request.hospital_id).first.id}"


















=begin

    SMS.fire_for_hospital(call_request.hospital, "#{call_request.name}님이 #{call_request.event.title} 이벤트에 참가하셨습니다.")
    @hos_num = call_request.hospital.phone
    if @hos_num == '' || @hos_num == ' '
      @hos_num = nil
    end

    @user_msg = "#{call_request.name} 회원님, \"#{call_request.event.title.truncate(20, separator: ' ')}\" 이벤트를 신청해주셔서 감사합니다.\n"
    if @hos_num.present?
      @user_msg = @user_msg + "#{call_request.hospital.name}에서 #{@hos_num} 번호로 안내 전화 드리겠습니다.\n"
    else
      @user_msg = @user_msg + "#{call_request.hospital.name}에서 안내 전화 드리겠습니다.\n"
    end
    bitly = Shortly::Clients::Bitly
    if Rails.env == "production"
      @short_url =  bitly.shorten("http://neo.goodoc.co.kr/hospitals/#{call_request.hospital.id}", {:apiKey => 'R_f8f64e38ff3fcafc3e40f32db16269c4', :login => 'kaipark'})
    else
      @short_url = nil
    end

    if call_request.hospital.id !=  116167
      @user_msg = @user_msg + "(병원 정보: #{@short_url.url} )\n전화 꼭 받아주세요.^^" if @short_url.present?
    end
      
    if call_request .funnel !=   "magicday"
      @user_msg = @user_msg + "\n\n 150만 국민 병원앱 굿닥, 아직도 안받으셨어요? 굿닥은 앱으로 해야 더 편해요"
    end
     # 앱 다운로드 받기-> https://play.google.com/store/apps/details?id=com.ksncho.hospitalinfo&hl=ko"
   
    if call_request.hospital.id == 34465
      @user_msg = "#{call_request.name}님, \"9월 한달 편강한의원 20% 착한 혜택 (중복혜택불가)\" 이벤트 신청되셨습니다.\n"
      @user_msg += "02-518-7777 번호로 안내 전화 드리겠습니다.\n"
      @user_msg += "(병원 정보: #{@short_url.url} )\n전화 꼭 받아주세요.^^" if @short_url.present?
    end

    if call_request.phone.present?
      if call_request.funnel !=   "magicday"
        MMS.fire_to_user(call_request.phone, @hos_num,@user_msg)
      else
        MMS.fire_to_magic_user(call_request.phone, @hos_num,@user_msg)
      end
    end

=end




  result = LogApi.post_to_esk "/smartcrm/webservice/xml_callrequest.asp", call_request.insert_xml_to_esk

  Rails.logger.info "Inser Result : #{result}"

  data = result["result"]["data"]

  if data.present?
    call_request.update_attributes(sex: data["sex"]) if data["sex"].present?
    call_request.update_attributes(age: data["age"]) if data["age"].present?
  end


 #   end
  end

  before_destroy do |call_request|
    result = LogApi.post_to_esk "/smartcrm/webservice/xml_callrequest.asp", call_request.insert_xml_to_esk
    Rails.logger.info "Delete Result : #{result}"
  end

  def having_hospital
    Hospital.new :name => self.hospital_name, :addr => self.hospital_addr
  end

  def having_event
    Event.new :title => self.event_title,
              :end_on => self.event_end_on,
              :discounted_price => self.event_discounted_price,
              :is_numerical_discounted_price => self.event_is_numerical_discounted_price,
              :numerical_discounted_price => self.event_numerical_discounted_price

  end

  def status_str
    CallRequest::STATUS[self.status]
  end

  def phone
    if self[:phone].present?
      self[:phone]
    elsif self.user.present?
      self.user.phone
    else
      ""
    end
  end

  def user_name
    if self.user_id.present?
      self.user.username
    elsif self.name.present?
      self.name
    else
      ""
    end
  end

  def insert_xml_to_esk

    cr = self
    if cr.event.is_temporary == false
      start_date = cr.event.start_on.strftime("%Y-%m-%d")
      end_date = cr.event.end_on.strftime("%Y-%m-%d")
    else
      start_date =  Date.today.beginning_of_month.strftime("%Y-%m-%d") 
      end_date =  Date.today.end_of_month.strftime("%Y-%m-%d")
    end
    one_depth = []
    two_depth = []
    event.event_categories.each do |cate|
      if cate.parent_id == 0
       one_depth.push(cate.title)
       two_depth.push(nil)
      else
       one_depth.push(cate.parent.title)
       two_depth.push(cate.title)
      end
    end

    one_depth.join(", ")
    two_depth.join(", ")


    os = OpenStruct.new(gu: "I",
                        id: cr.id,
                        hospital_id: "hsk",
                        event_id: cr.event_id,
                        user_id: cr.user_id,
                        device: cr.device,
                        status: cr.status,
                        name: cr.name,
                        phone: cr.phone.gsub("+82","").gsub("-", ""),
                        content: cr.content)

    xml = ::Builder::XmlMarkup.new(indent: 3); xml.target!
    xml.instruct!

    xml.CallRequests {
      xml.CallRequest{
        xml.gu do xml.cdata! "I" end
        xml.id do xml.cdata! cr.id.to_s end
        xml.hospital_id do xml.cdata! "hsk" end
        xml.event_id do xml.cdata! cr.event_id.to_s end
        xml.event_title do  xml.cdata! cr.event.title end
        xml.user_id do xml.cdata! cr.user_id.to_s end  if cr.user_id.present?
        xml.user_id do xml.cdata! "" end  if cr.user_id.blank?
        xml.start_on do xml.cdata! start_date end
        xml.end_on do xml.cdata! end_date end
        xml.category1 do xml.cdata! one_depth.join(", ") end
        xml.ctaegory2 do xml.cdata! two_depth.join(", ") end
 #       xml.device(cr.device)
        xml.status do xml.cdata! cr.status.to_s end
        xml.name do xml.cdata! cr.name end
        xml.phone do xml.cdata! cr.phone.gsub("+82","").gsub("-", "") end
        xml.content do xml.cdata! cr.content end
        xml.call_time do xml.cdata! cr.call_time end
      }
    }
    xml.target!

  end

  def delete_xml_to_esk

    require "net/http"
    require "rexml/document"
    require "builder"

    cr = self
    xml = ::Builder::XmlMarkup.new
    xml.instruct!
    xml.CallRequests {
      xml.CallRequest{
        xml.gu do xml.cdata! "D" end
        xml.id do xml.cdata! cr.id end
        xml.hospital_id do xml.cdata! "hsk" end
        xml.event_id do xml.cdata! cr.event_id end
        xml.event_title do  xml.cdata! cr.event.title end
        xml.user_id do xml.cdata! cr.user_id end  if cr.user_id.present?
        xml.user_id do xml.cdata! "" end  if cr.user_id.blank?
 #       xml.device(cr.device)
        xml.status do xml.cdata! cr.status end
        xml.name do xml.cdata! cr.name end
        xml.phone do xml.cdata! cr.phone.gsub("+82","").gsub("-", "") end
        xml.content do xml.cdata! cr.content end
        xml.call_time do xml.cdata! cr.call_time end
      }
    }
    xml.target!

  end



end
