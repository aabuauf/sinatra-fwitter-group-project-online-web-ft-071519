class User < ActiveRecord::Base
  has_secure_password
  has_many :tweets

  def slug
    newarray =[]
    self.username.split(" ").each do|name|
      newarray << name.downcase
    end
  newarray = newarray.join("-")
  end 
  

  def self.find_by_slug(slugyname)
    self.all.find do |i| 
      i.slug == slugyname
    end
  end
end