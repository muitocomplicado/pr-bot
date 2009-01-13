class Server
  include DataMapper::Resource

  property :name, String, :nullable => false, :length => 255, :key => true
  property :ip, String, :nullable => false
  property :added_by, String, :nullable => false, :length => 255
end