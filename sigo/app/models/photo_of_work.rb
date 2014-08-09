class PhotoOfWork < ActiveRecord::Base
  belongs_to :folder
  has_attached_file :photo, :default_url => lambda { |image| ActionController::Base.helpers.asset_path('NotAvailable300.png') }
  validates_attachment_content_type :photo, :content_type => [ /\Aimage\/.*\Z/],  :in => 0.megabytes..40.megabytes
end