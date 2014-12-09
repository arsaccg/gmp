class Extensionscontrol < ActiveRecord::Base
	belongs_to :project

	validates :files, presence: true
  	validates :files,
    	attachment_content_type: { content_type: "application/pdf" },
    	attachment_size: { less_than: 5.megabytes }

	has_attached_file :files, styles: {
	    thumb: '100x100>',
	    square: '200x200#',
	    medium: '300x300>'
	}

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
