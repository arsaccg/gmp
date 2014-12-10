class AddAttachmentDocumentToExtensionscontrols < ActiveRecord::Migration
  def self.up
    change_table :extensionscontrols do |t|
      t.attachment :document
    end
  end

  def self.down
    drop_attached_file :extensionscontrols, :document
  end
end
