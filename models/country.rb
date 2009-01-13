class Country
  include DataMapper::Resource

  property :nick, String, :nullable => false, :limit => 255, :key => true
  property :country, String, :nullable => false, :limit => 255
  property :added_by, String, :nullable => false, :limit => 255
end