class Hardcoded
  include DataMapper::Resource

  property :thing, String, :nullable => false, :limit => 255, :key => true
  property :hardcoded, Boolean, :nullable => false, :default => true
  property :added_by, String, :nullable => false, :limit => 255
end