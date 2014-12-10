class Extensionscontrol < ActiveRecord::Base
	belongs_to :project

	has_attached_file :document
	validates_attachment_content_type :document, :content_type => ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'],  :in => 0.megabytes..40.megabytes

	STATUS_HASH = {
		"requested" => "Presentado",
		"approved" => "Aprobado",
		"disproved" => "Denegado",
		"approved_p" => "Aprobado Parcialmente"
	}
	
	state_machine :status, :initial => :requested do
		event :approve do
			transition :requested => :approved
		end
		event :disprove do
			transition :requested => :disproved
		end
	end
end
