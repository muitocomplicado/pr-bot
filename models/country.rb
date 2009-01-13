class Country
  include DataMapper::Resource

  property :nick, String, :nullable => false, :length => 255, :key => true
  property :country, String, :nullable => false, :length => 255
  property :added_by, String, :nullable => false, :length => 255
end