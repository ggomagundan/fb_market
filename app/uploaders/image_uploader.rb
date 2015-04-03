# -*- encoding : utf-8 -*-

#require File.join(Rails.root, "lib", "carrier_wave", "delayed_job")

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

#  include CarrierWave::Delayed::Job
  # http://www.freezzo.com/2011/01/06/how-to-use-delayed-job-to-handle-your-carrierwave-processing/

  CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

 def self.size(file)
   uploaded?(file) ? file.size : nil
 end

=begin
 MAX_FILENAME_LENGTH = 64 # arbitrary limit, your milage may vary


 def cache_name
   File.join(cache_id, full_original_filename) if cache_id and original_filename
 end

 def original_filename=(filename)
   raise CarrierWave::InvalidParameter, "invalid filename" if filename =~ CarrierWave::SanitizedFile.sanitize_regexp
   @original_filename = filename

 end

 def filename
   puts file
   @filename
 end

 def store!(new_file=nil)
   binding.pry
   cache!(new_file) if new_file && ((@cache_id != parent_cache_id) || @cache_id.nil?)
   if @file and @cache_id
     with_callbacks(:store, new_file) do
       new_file = storage.store!(@file)
       @file.delete if (delete_tmp_file_after_storage && ! move_to_store)
       delete_cache_id
       @file = new_file
       @cache_id = nil
     end
   end
 end

 def store_path(for_file=filename)
   File.join([store_dir, full_filename(for_file)].compact)
 end

 def full_original_filename
   filename = super

   return filename if !filename.present?

   extension = File.extname(filename)
   if File.basename(filename, extension).length > MAX_FILENAME_LENGTH - 10
     basename = "#{model.class.to_s.underscore}_#{model.id}" if version_name.blank?
     basename = "#{version_name}_#{model.class.to_s.underscore}_#{model.id}" if version_name.present?
     puts basename
   else
     basename = File.basename(filename, extension)[0...MAX_FILENAME_LENGTH]
   end
   basename + extension
 end
#http://stackoverflow.com/questions/16472894/modify-filename-before-saving-with-carrierwave
=end


  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:

  def store_dir
    if Rails.env == "test"
      "images_for_test"
    else
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  end

  version :featuring, :if => :is_featuring? do
    process :dynamic_resize => :featuring
  end
  version :android, :if => :is_android? do
    #process :dynamic_resize_to_fill => :android
    process :dynamic_resize => :android
  end
  version :iphone, :if => :is_iphone? do
    process :dynamic_resize => :iphone
  end

  version :thumbnail, :if => :is_thumbnail? do
    process :dynamic_resize => :thumbnail
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def as_json img
    hash = {:url => self.url}
    self.versions.each do |k, v|
      hash[k] = v.url unless v.blank?
    end
    hash
  end
  

  #def as_json(params = {})
    #return {} if self.blank?
    #if self.compressed.present?
      #hash = {:url => self.compressed.url}
    #else
      #hash = {:url => self.url}
    #end
    #self.versions.each do |k, v|
      #hash[k] = v.url unless v.blank? || k == :compressed
    #end
    #hash
  #end
  
  def dynamic_resize_to_fill(version)
    size = model.class::const_get(version.upcase)[mounted_as]
    resize_to_fill *size
  end

  def dynamic_resize(version)
    size = model.class::const_get(version.upcase)[mounted_as]
    if size.last.nil?
      resize_to_limit *size
    else
      resize_to_fill *size
    end
  end



  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
  protected

  def method_missing(method_name, *args, &block)
    if method_name =~ /^is_(.+)\?/
      version_name = method_name.to_s.gsub("is_", "").gsub("?", "").upcase
      begin
        return model.class.const_defined?(version_name) && model.class.const_get(version_name).keys.include?(mounted_as)
      rescue
        return false
      end
    else
      super
    end
  end

  def down_quality
    manipulate! do |img|
      if img.filesize > (1024 * 1024)
        devider = img.filesize.to_f / (1024 * 1024).to_f
        img.write(current_path){

          self.quality = 85
          self.format = "JPG"
        } 
        img = yield(img) if block_given?
      end
      img
    end
  end

  def remove_alpha_channel
    convert(:rgb)
  end

  #def is_thumbnail? img
    #begin
      #model.class::THUMBNAIL.keys.include? mounted_as
    #rescue
      #false
    #end
  #end
  # 

end
