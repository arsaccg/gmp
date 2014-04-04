class LinkTime < ActiveRecord::Base
  def self.from(x)
    where("date >= ?", x)
  end
  def self.to(x)
    where("date <= ?", x)
  end
end