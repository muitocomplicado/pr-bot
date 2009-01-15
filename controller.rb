# Controller for the Pr leaf.

require 'rubygems'

gem 'hpricot', '~> 0.6.164'
gem 'simple-rss', '~> 1.1'
gem 'facets', '~> 2.5.0'

require 'hpricot'
require 'simple-rss'
require 'open-uri'
require 'facets/random'
require 'uri'

class Controller < Autumn::Leaf
  before_filter :check_message, 
                :except => [ :about, :help, :latest, :hardcoded, :nuke, :jdam, :arty, 
                             :mortars, :ied, :grenade, :rifle, :sniper ]
  before_filter :downcase_message, :only => [ :leet, :hardcoded, :likesmen, :server ]
  
  def about_command(stem, sender, reply_to, msg)
    "Hello, I'm a PR bot. I do cool things, so type !help for more info"
  end
  
  def help_command(stem, sender, reply_to, msg)
  end
  
  def released_command(stem, sender, reply_to, msg)
    VERSIONS.include?(msg.to_f) ? "yes" : "no"
  end
  
  def leet_command(stem, sender, reply_to, msg)
    if msg =~ /^(\S+)$/i then
      LEET.include?(msg) ? "yes" : "no way"
    else
      "type only a nickname"
    end
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
        set_country( nick, country, sender ) ? get_country( nick ) : "error"
      else
        get_country( nick )
      end
    end
  end
  
  def hardcoded_command(stem, sender, reply_to, msg)
    if msg.nil? then
      thing = 'random'
      hardcoded = nil
    elsif msg =~ /^(.*)\s+(true|false)$/i
      thing = $1.downcase
      hardcoded = ( $2 == 'true' ? true : false )
    else
      thing = msg
      hardcoded = nil
    end
    
    database(:local) do
      if thing == 'random'
        return get_random_hardcoded
      end
      
      if ! hardcoded.nil? then
        set_hardcoded( thing, hardcoded, sender ) ? get_hardcoded( thing ) : "error"
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
  
  def nuke_command(stem, sender, reply_to, msg)
    "KABOOOOOOOOOOOOOOMMMMMMMMMMMMM"
  end
  
  def arty_command(stem, sender, reply_to, msg)
    "BOOOOOOM    BOOOOOOM    BOOOOOOM    BOOOOOOM"
  end
  
  def mortars_command(stem, sender, reply_to, msg)
    "BOOOM  BOOOM  BOOOM  BOOOM  BOOOM  BOOOM"
  end
  
  def jdam_command(stem, sender, reply_to, msg)
    "BADABOOOOOOOOOOOM"
  end
  
  def ied_command(stem, sender, reply_to, msg)
    "BOOOOOOM ALLAAAAAH"
  end
  
  def grenade_command(stem, sender, reply_to, msg)
    "BOOM"
  end
  
  def rifle_command(stem, sender, reply_to, msg)
    "BANG"
  end
  
  def sniper_command(stem, sender, reply_to, msg)
    "BANG      CLACK-CLITCH"
  end
  
  def server_command(stem, sender, reply_to, msg)
    if msg =~ /^(.*)\s+(([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)\:([0-9]+))$/i then
      name = $1.downcase
      ip = $2
      # ip = "64.34.161.157:16567"
    else
      name = msg
      ip = nil
    end
    
    database(:local) do
      if ! ip.nil? then
        set_server( name, ip, sender ) ? get_server( name ) : "error"
      else
        get_server( name )
      end
    end
  end
  
  def magic_eight_ball_command(stem, sender, reply_to, msg)
    MAGIC8BALL.at_rand
  end
  
  def magic8ball_command(stem, sender, reply_to, msg)
    magic_eight_ball_command(stem, sender, reply_to, msg)
  end
  
  def m8b_command(stem, sender, reply_to, msg)
    magic_eight_ball_command(stem, sender, reply_to, msg)
  end
  
  def google_command(stem, sender, reply_to, msg)
    URI.escape("http://www.letmegooglethatforyou.com/?q=" + msg )
  end
  
  private
  
  VERSIONS = [ 0.1, 0.2, 0.32, 0.4, 0.5, 0.6, 0.7, 0.75, 0.8 ]
  
  LEET = [ 'db', 'dbzao', 'ancientman', 'e-gor', 'prbot', 'projectreality', 'realitymod', 'pr', 'prm' ]
  
  LIKESMEN = [ 'rhino', 'katarn' ]
  LIKESMEN_NOWAY = [ 'dbzao' ]
  
  MAGIC8BALL = [ "As I see it, yes", "It is certain", "It is decidedly so", "Most likely", "Outlook good", "Signs point to yes", "Without a doubt", "Yes", "Yes - definitely", "You may rely on it", "Ask again later", "Better not tell you now", "Cannot predict now", "Concentrate and ask again", "Reply hazy, try again", "Don't count on it", "My reply is no", "My sources say no", "Outlook not so good", "Very doubtful" ]
  
  def set_server( name, ip, sender )
    s = Server.get( name )
    if s
      s.update_attributes( :ip => ip, :added_by => sender[:nick] )
    else
      Server.create( :name => name, :ip => ip, :added_by => sender[:nick] )
    end
  end
  
  def get_server( name )
    
    s = Server.get( name )
    return "sorry, I don't know that server, but you can add it using !server <name> <ip>:<port>" if s.nil?
    
    begin
      f = open("http://www.gametracker.com/server_info/#{s.ip}/")
      doc = Hpricot(f)
    rescue
      return '404 bad server address'
    end
    
    error = doc.at("//title").inner_html
    return 'bad server address' if error.include?( "No Statistics Available" )
    
    server = doc.at("//div[@class='server_header_title']").inner_html.strip
    players = doc.at("//span[@id='HTML_num_players']").inner_html.strip
    max = doc.at("//span[@id='HTML_max_players']").inner_html.strip
    map = doc.at("//div[@class='si_map_header']").inner_html.strip
    country = doc.at("//img[@class='flag']")['src'].match(/([a-z]{2})\.gif/i)[1].uppercase
    
    "%s | %d/%d %s | %s (by %s)" % [ server, players, max, map, country, s.added_by ]
    
  end
  
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
  
  def get_random_hardcoded
    h = Hardcoded.all.at_rand
    h.thing + ' = ' + ( h.hardcoded ? "hardcoded" : "not hardcoded" ) + " (by " + h.added_by + ")"
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
      stem.message "Type !help to learn how to use this command", channel
      false
    else
      true
    end
  end
  
  def downcase_message_filter(stem, channel, sender, command, msg, opts)
    msg.downcase! if ! msg.nil?
    true
  end
  
end
