class PhotoOfWork < ActiveRecord::Base
	has_attached_file :photo, :default_url => lambda { |image| ActionController::Base.helpers.asset_path('NotAvailable300.png') }
  validates_attachment_content_type :photo, :content_type => [ /\Aimage\/.*\Z/]
end
