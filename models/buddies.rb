class Buddies
  include DataMapper::Resource

  property :nick, String, :nullable => false, :length => 255, :key => true
  property :buddy, String, :nullable => false, :length => 255, :key => true
end