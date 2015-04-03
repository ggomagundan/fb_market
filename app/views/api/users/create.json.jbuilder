json.status @jsonResult.status
json.message @jsonResult.message

if @jsonResult.object.present?
  json.user do |json|
    json.token @jsonResult.object.access_token
    json.(@jsonResult.object, :id, :email, :phone, :picture, :sex, :job, :age)
    json.(@jsonResult.object, :username)
  end
end
