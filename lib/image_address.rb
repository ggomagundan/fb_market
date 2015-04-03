# -*- encoding : utf-8 -*-
module ImageAddress

  def self.get_address(url, request)
    params = request.try("params")
    if params.present? && params[:ver] ==  "v2" && params[:sub_ver].to_i >= 20150325
      "http://#{request.env["HTTP_HOST"]}#{url}"
    elsif params.present?
      url
    else
      nil
    end


  end

end
