# Controller for the Pr leaf.
require 'simple-rss'
require 'open-uri'

class Controller < Autumn::Leaf
  before_filter :check_message, :except => [ :about, :latest ]
  before_filter :downcase_message, :only => [ :leet, :country, :hardcoded, :likesmen ]
  
  # Typing "!about" displays some basic information about this leaf.
  
  def about_command(stem, sender, reply_to, msg)
  end
  
  def released_command(stem, sender, reply_to, msg)
    VERSIONS.include?(msg.to_f) ? "yes" : "no"
  end
  
  def leet_command(stem, sender, reply_to, msg)
    LEET.include?(msg) ? "yes" : "no way"
  end
  
  def country_command(stem, sender, reply_to, msg)
    COUNTRIES[msg] ||  "sorry, I don't know"
  end
  
  def hardcoded_command(stem, sender, reply_to, msg)
    if HARDCODED.include?(msg) then
      "yes"
    elsif NOTHARDCODED.include?(msg) then
      "no"
    else
      "don't know"
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
  
  LEET = [ 'db', 'dbzao', 'ancientman', 'e-gor' ]
  
  LIKESMEN = [ 'rhino', 'katarn' ]
  LIKESMEN_NOWAY = [ 'dbzao' ]
  
  HARDCODED = [ 'fastropes', 'players' ]
  NOTHARDCODED = []
  
  COUNTRIES = {
    'ancientman' => 'Australia, with all the kangaroos',
    'dbzao' => 'Brazil, with all the monkeys',
    'e-gor' => 'The Mighty British Empire',
    'afterdune' => 'Netherlands, Holland, Dutch land, take your pick',
    'prbot' => 'If I tell you, I have to kill you',
    'q' => 'The interwebz',
    'fuzzhead' => 'Canada, with all the beavers',
    'katarn' => 'America, Fuck Yeah!'
  }
  
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
