# Controller for the Pr leaf.
require 'simple-rss'
require 'open-uri'

class Controller < Autumn::Leaf
  before_filter :check_message, :except => [ :about, :latest ]
  before_filter :downcase_message, :only => [ :leet, :hardcoded, :likesmen ]
  
  def about_command(stem, sender, reply_to, msg)
  end
  
  def released_command(stem, sender, reply_to, msg)
    VERSIONS.include?(msg.to_f) ? "yes" : "no"
  end
  
  def leet_command(stem, sender, reply_to, msg)
    LEET.include?(msg) ? "yes" : "no way"
  end
  
  def country_command(stem, sender, reply_to, msg)
    
    if msg =~ /^(\S+)\s+(.*)$/i then
      nick = $1.downcase
      country = $2
    else
      nick = msg.downcase
      country = nil
    end
    
    database(:local) do
      if country then
        set_country( nick, country, sender ) ? country : "error"
      else
        get_country( nick )
      end
    end
  end
  
  def hardcoded_command(stem, sender, reply_to, msg)
    if msg =~ /^(.*)\s+(true|false)$/i then
      thing = $1.downcase
      hardcoded = ( $2 == 'true' ? true : false )
    else
      thing = msg
      hardcoded = nil
    end
    
    database(:local) do
      if ! hardcoded.nil? then
        set_hardcoded( thing, hardcoded, sender ) ? ( hardcoded ? "hardcoded" : "not hardcoded" ) : "error"
      else
        get_hardcoded( thing )
      end
    end
  end
  
  def likesmen_command(stem, sender, reply_to, msg)
    LIKESMEN.include?(msg) ? "yes" : ( LIKESMEN_NOWAY.include?(msg) ? "no" : "maybe" )
  end
  
  def latest_command(stem, sender, reply_to, msg)
    rss = SimpleRSS.parse(open('http://www.realitymod.com/forum/external.php?type=RSS2'))
    var :rss => rss.items[0..4]
  end
  
  private
  
  VERSIONS = [ 0.1, 0.2, 0.32, 0.4, 0.5, 0.6, 0.7, 0.75, 0.8 ]
  
  LEET = [ 'db', 'dbzao', 'ancientman', 'e-gor', 'prbot' ]
  
  LIKESMEN = [ 'rhino', 'katarn' ]
  LIKESMEN_NOWAY = [ 'dbzao' ]
  
  def set_hardcoded( thing, hardcoded, sender )
    h = Hardcoded.get( thing )
    if h
      h.update_attributes( :hardcoded => hardcoded, :added_by => sender[:nick] )
    else
      Hardcoded.create( :thing => thing, :hardcoded => hardcoded, :added_by => sender[:nick] )
    end
  end
  
  def get_hardcoded( thing )
    h = Hardcoded.get( thing )
    if h
      ( h.hardcoded ? "yes" : "no" ) + " (by " + h.added_by + ")"
    else
      "sorry, I don't know, but you can tell me using !hardcoded <thing> true|false"
    end
  end
  
  def set_country( nick, country, sender )
    c = Country.get( nick )
    if c
      c.update_attributes( :country => country, :added_by => sender[:nick] )
    else
      Country.create( :nick => nick, :country => country, :added_by => sender[:nick] )
    end
  end
  
  def get_country( nick )
    c = Country.get( nick )
    if c
      c.country + " (by " + c.added_by + ")"
    else
      "sorry, I don't know, but you can add it using !country <nick> <country>"
    end
  end
  
  def check_message_filter(stem, channel, sender, command, msg, opts)
    if msg.nil? then 
      stem.message "Type !about to learn how to use this command", channel
    else
      true
    end
  end
  
  def downcase_message_filter(stem, channel, sender, command, msg, opts)
    msg.downcase!
    true
  end
  
end
