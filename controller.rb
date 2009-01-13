# Controller for the Pr leaf.
require 'simple-rss'
require 'open-uri'

class Controller < Autumn::Leaf
  
  # Typing "!about" displays some basic information about this leaf.
  
  def about_command(stem, sender, reply_to, msg)
  end
  
  def released_command(stem, sender, reply_to, msg)
    if msg.nil? then render :help
    else released?( msg.to_f ) end
  end
  
  def leet_command(stem, sender, reply_to, msg)
    if msg.nil? then render :help
    else leet?( msg.downcase ) end
  end
  
  def country_command(stem, sender, reply_to, msg)
    if msg.nil? then render :help
    else country( msg.downcase ) end
  end
  
  def hardcoded_command(stem, sender, reply_to, msg)
    if msg.nil? then render :help
    else hardcoded?( msg.downcase ) end
  end
  
  def likesmen_command(stem, sender, reply_to, msg)
    if msg.nil? then render :help
    else likesmen?( msg.downcase ) end
  end
  
  def latest_command(stem, sender, reply_to, msg)
    rss = SimpleRSS.parse(open('http://www.realitymod.com/forum/external.php?type=RSS2'))
    var :rss => rss.items[0..4]
  end
  
  private
  
  def released?( version )
    [ 0.1, 0.2, 0.32, 0.4, 0.5, 0.6, 0.7, 0.75, 0.8 ].include?(version) ? "yes" : "no"
  end
  
  def leet?( nick )
    [ 'db', 'dbzao', 'ancientman', 'e-gor' ].include?(nick) ? "yes" : "no way"
  end
  
  def likesmen?( nick )
    [ 'rhino', 'katarn' ].include?(nick) ? "yes" : ( [ 'dbzao' ].include?(nick) ? "no" : "maybe" )
  end
  
  HARDCODED = [ 'fastropes', 'players' ]
  NOTHARDCODED = []
  
  def hardcoded?( msg )
    if HARDCODED.include?(msg) then
      "yes"
    elsif NOTHARDCODED.include?(msg) then
      "no"
    else
      "don't know"
    end
  end
  
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
  
  def country( nick )
    COUNTRIES[nick] ||  "sorry, I don't know"
  end
  
end
