class Extensionscontrol < ActiveRecord::Base
	belongs_to :project

	has_attached_file :files,
                    :url  => "/assets/products/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/assets/products/:id/:style/:basename.:extension"

  	#validates_attachment_content_type :pdf,
    #  :content_type => [ 'application/pdf' ],
    #  :message => "only pdf files are allowed"

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
