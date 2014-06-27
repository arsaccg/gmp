class DownloadSoftware < ActiveRecord::Base
	has_attached_file :file
	validates_attachment_content_type :file, :content_type => ['application/zip', 'application/x-zip-compressed']
end
