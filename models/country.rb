# class Country
#   include DataMapper::Resource
# 
#   property :nick, String, :nullable => false, :limit => 16
#   property :country, String, :nullable => false, :limit => 255
#   property :updated_at, DateTime, :default => 'NOW()'
# end