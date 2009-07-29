# Controller for the Pr leaf.

require 'rubygems'

# gem 'hpricot', '~> 0.6.164'
gem 'simple-rss', '~> 1.1'
gem 'facets', '~> 2.5.0'
gem 'json', '~> 1.1.7'

# require 'hpricot'
require 'simple-rss'
require 'open-uri'
require 'facets/random'
require 'uri'
require 'time'
require 'cgi'
require 'net/http'
require 'json'

class Controller < Autumn::Leaf
  before_filter :check_message, 
                :except => [ :about, :help, :fail, :latest, :hardcoded, :nuke, :jdam, :arty, :translate, :tr,
                             :mortars, :ied, :grenade, :rifle, :sniper, :cake, :buddies, :buddylist, :commands ]
  before_filter :downcase_message, 
                :only => [ :leet, :hardcoded, :likesmen, :server, :servers, :player, :players, :buddies, :decide ]
  before_filter :strip_message
  
  def about_command(stem, sender, reply_to, msg)
    help_command(stem, sender, reply_to, msg)
  end
  
  def help_command(stem, sender, reply_to, msg)
  end
  
  def release_command(stem, sender, reply_to, msg)
    if VERSIONS_ALMOST.include?(msg.to_f) then
      "Alright, I'll submit your request to release " + msg + " but it may take some time, I am quite busy..."
    else
      "You fail..."
    end
  end
  
  def released_command(stem, sender, reply_to, msg)
    # VERSIONS.include?(msg.to_f) ? "yes" : "no"
    VERSIONS.include?(msg.to_f) ? "yes" : ( VERSIONS_ALMOST.include?(msg.to_f) ? "IMMINENTLY!!!" : "no" )
  end
  
  def leet_command(stem, sender, reply_to, msg)
    if msg =~ /^(\S+)$/i then
      LEET.include?(msg) ? "yes" : "no way"
    else
      "type only a nickname"
    end
  end
  
  def fail_command(stem, sender, reply_to, msg)
    msg.to_s + ' ' + [ '', 'epic', 'uber', 'mega', 'super', 'hyper', 'constant', 'exponential', 'unlimited', 'breaking', 'ugly', 'dark force', 'wow', 'concrete', 'pirate' ].at_rand + ' fail'
  end
  
  def buddylist_command(stem, sender, reply_to, msg)
    database(:local) do
      get_buddies( sender[:nick] ) || buddies_error
    end
  end
  
  def buddies_command(stem, sender, reply_to, msg)
    database(:local) do
      if msg then
        set_buddies( sender[:nick], msg.split(' ') ) ? ( get_buddies( sender[:nick] ) || buddies_error ) : "error"
      else
        list = get_buddies( sender[:nick] )
        if list
          players_command(stem, sender, reply_to, list)
        else
          buddies_error
        end
      end
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
    LIKESMEN.include?(msg) ? "yes" : ( LIKESMEN_NOWAY.include?(msg) ? "no" : LIKESMEN_PROBABLY.at_rand )
  end
  
  def latest_command(stem, sender, reply_to, msg)
    rss = SimpleRSS.parse(open('http://www.realitymod.com/forum/external.php?type=RSS2'))
    var :rss => rss.items[0..4]
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
  
  def servers_command(stem, sender, reply_to, msg)
    
    database(:local) do
      
      ips = []
      list = Server.all( :name => msg.split(' ') )
      
      if list then
        list.each { |s| ips << s.ip }
      end
      
      return 'servers are empty' if ips.empty?
      
      list = []
      ips.each { |ip| 
        info = get_server_info( ip )
        list << info if info
      }
      
      list = list.slice(0,5) if list.length > 5
      var :servers => list
      
    end
    
  end
  
  def player_command(stem, sender, reply_to, msg)
    get_player_info( msg ) || 'player not found'
  end
  
  def players_command(stem, sender, reply_to, msg)
    list = []
    msg.split(' ').each{ |name|
      list = list | get_player_info( name, true )
    }
    
    list = list.slice(0,5) if list.length > 5
    var :players => list
    render :players
  end
  
  def decide_command(stem, sender, reply_to, msg)
    if msg.include? ',' or msg.include? ' or ' then
      decision = msg.gsub(', or', ' or ').gsub(',or', ' or ').gsub(',', ' or ').gsub('?', '').gsub('should i ', '').gsub('should we ', '')
      decision = decision.split(' or ').at_rand.capitalize.strip
      if decision == '' or decision.downcase ==  'or' then
        'Sorry, I don\'t know :('
      else
        decision
      end
    else
      'You could at least type the question properly...'
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
  
  def prbot_command(stem, sender, reply_to, msg)
    magic_eight_ball_command(stem, sender, reply_to, msg)
  end
  
  def google_command(stem, sender, reply_to, msg)
    URI.escape("http://www.lmgtfy.com/?q=" + msg )
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
  
  def cake_command(stem, sender, reply_to, msg)
    "the cake is a lie"
  end
  
  def tr_command(stem, sender, reply_to, msg)
    translate_command(stem, sender, reply_to, msg)
  end
  
  def translate_command(stem, sender, reply_to, msg)
    
    base_translate = 'http://ajax.googleapis.com/ajax/services/language/translate'
    base_detect    = 'http://ajax.googleapis.com/ajax/services/language/detect' 

    params = {
      :q => msg,
      :v => 1.0  
    }

    query = params.map{ |k,v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
    response = Net::HTTP.get_response( URI.parse( "#{base_detect}?#{query}" ) )
    json = JSON.parse( response.body )

    if json['responseStatus'] == 200
      from = json['responseData']['language']
    else
      return json['responseDetails']
    end

    params = {
      :langpair => "#{from}|en", 
      :q => msg,
      :v => 1.0  
    }

    query = params.map{ |k,v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
    response = Net::HTTP.get_response( URI.parse( "#{base_translate}?#{query}" ) )
    json = JSON.parse( response.body )

    if json['responseStatus'] == 200
      return json['responseData']['translatedText'] + " (#{from})" 
    else
      return json['responseDetails']
    end
    
  end
  
  private
  
  VERSIONS = [ 0.1, 0.2, 0.32, 0.4, 0.5, 0.6, 0.7, 0.75, 0.8, 0.85, 0.86 ]
  VERSIONS_ALMOST = []
  
  LEET = [ 'db', 'dbzao', 'ancientman', 'afterdune', 'e-gor',  'masaq', 'prbot', 'projectreality', 'realitymod', 'pr', 'prm' ]
  
  LIKESMEN = [ 'rhino', 'katarn' ]
  LIKESMEN_NOWAY = [ 'dbzao', 'ancientman' ]
  LIKESMEN_PROBABLY = [ 'probably', 'maybe', 'almost certain', 'most likely', 'signs point to yes' ]
  
  MAGIC8BALL = [ "As I see it, yes", "It is certain", "It is decidedly so", "Most likely", "Outlook good", "Signs point to yes", "Without a doubt", "Yes", "Yes - definitely", "You may rely on it", "Ask again later", "Better not tell you now", "Cannot predict now", "Concentrate and ask again", "Reply hazy, try again", "Don't count on it", "My reply is no", "My sources say no", "Outlook not so good", "Very doubtful", "You're retarded, I'm not answering that question" ]
  
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
    return "I don't know that server, but you can add it using !server <name> <ip>:<port>" if s.nil?
    
    get_server_info( s.ip ) || "server is empty"
    
  end
  
  def update_servers_cache
    if @cache_servers.nil? || @cache_servers < Time.now - 300 then
      
      @cache_servers = Time.now
      @servers = Hash.new
      
      open('http://realitymodfiles.com/egor/currentservers.txt') { |f|
        f.each_line { |line| 
          if line =~ /^(.*)\s+\|\|\s+(([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)\:([0-9]+))/i then
            @servers[$2] = $1.squeeze(" ")
          end
        }
      }
      
    end
  end
  
  def update_players_cache
    if @cache_players.nil? || @cache_players < Time.now - 300 then
      
      @cache_players = Time.now
      @players = Hash.new
      
      open('http://realitymodfiles.com/egor/currentplayers.txt') { |f|
        f.each_line { |line| 
          if line =~ /^(.*)\s+\|\|\s+(.*)\s+\|\|\s+(([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)\:([0-9]+))/i then
            @players[$1.squeeze(" ").strip] = $3
          end
        }
      }
      
    end
  end
  
  def get_server_info( address )
    update_servers_cache
    @servers[address]
  end
  
  def get_player_info( name, multiple=false )
    update_players_cache
    
    res = []
    @players.each_pair { |nick, address|
      if nick.downcase.include?( name ) then
        res << ( nick + ' -> ' + get_server_info(address) )
        return res[0] unless multiple
      end
    }
    
    if multiple then res else nil end
    
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
      "I don't know, but you can tell me using !hardcoded <thing> true|false"
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
      "I don't know, but you can add it using !country <nick> <country>"
    end
  end
  
  def get_buddies( nick )
    b = Buddies.all( :nick => nick )
    if b and b.length > 0 then
      list = []
      b.each { |buddy| list << buddy.buddy }
      list.join(' ')
    end
  end
  
  def set_buddies( nick, buddies )
    buddies.each { |buddy|
      b = Buddies.get( nick, buddy )
      if b
        b.destroy
      else
        Buddies.create( :nick => nick, :buddy => buddy )
      end
    }
  end
  
  def buddies_error
    "No buddies registered for you, but you can add some using !buddies <nick> <nick> ... <nick>"
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
  
  def strip_message_filter(stem, channel, sender, command, msg, opts)
    msg.strip! if ! msg.nil?
    true
  end
  
end
