
# lib/cinch/plugins/selfietrain.rb

require 'cinch'
require 'yaml'

module Cinch::Plugins
  class SelfieTrain
    include Cinch::Plugin

    begin
      wdir = "#{Dir.home}/totes/"
      $selfie_count = YAML.load_file(wdir + 'dbs/selfie_count.yaml')
      $selfie_stickers = YAML.load_file(wdir + 'dbs/selfie_stickers.yaml')
    rescue
      $selfie_count = {}
      $selfie_stickers = {}
    end

$selfie = false # toggle selfie train
    
    def colorify(string)
      colors = [:aqua, :black, :blue, :brown, :green, :grey, :lime, :orange, :pink, :purple, :red, :royal, :silver, :teal, :white, :yellow]
      buffer = ''
      string.each_char do |i|
        buffer += Format(colors[rand(colors.length) - 1], i)
      end
      buffer
    end

    def save_hack(db, dbname)
      File.open("#{Dir.home}/totes/dbs/#{dbname}.yaml", 'w') { |hash| hash.puts db.to_yaml }
    end

# selfie train! CHOO CHOO!
    match(/selfietrain (.+)/, method:  :selfietrain)
    def selfietrain(m, time)
      if ($admins.include? m.user.nick) && (time.to_i > 0) && (time.to_i <= 10) # selfie trains can be 1-10 minutes long
        if (time.to_i > 0) && ($selfie == false)
          m.reply "#{colorify("#{time} minute selfie train started by #{m.user.nick}! choo choo!".upcase)}"
	  $selfie = true
        end
        start = Time.now.min
        while (Time.now.min < start + time.to_i) && ($selfie == true)
        end
        $selfie = false
        m.reply colorify('the selfie train has ended, folks!'.upcase)
      elsif ($admins.include? m.user.nick) && (['stahp', 'stop', 'quit', 'no', 'end', 'putput', 'put put'].include? time.to_s)
        $selfie = false
      end
      save_hack($selfie_count, 'selfie_count')
      save_hack($selfie_stickers, 'selfie_stickers')
    end

    match(/selfie (.+)/, method:  :selfie)
    def selfie(m, link)
      stickers = {
        1 => 'Selfie Train Participant',
        3 => 'Serial Selfie-ist',
	5 => 'Quintessential Selfie-Taker',
	7 => 'Septuplets!',
	12 => 'Dodecanese Tourist',
	17 => 'Selfie Primetime',
	29 => 'We Ran Out of Stickers for You'
      }
      if ($selfie == true) && (link.match('imgur.com'))
        if $selfie_count.key? m.user.nick
          $selfie_count[m.user.nick] = $selfie_count[m.user.nick] + 1

          if $selfie_count[m.user.nick] == 3
	    $selfie_stickers[m.user.nick] = stickers[3]
            m.reply "#{m.user.nick} has earned the '#{stickers[3]}' Selfie Sticker!"

	  elsif $selfie_count[m.user.nick] == 5
	    $selfie_stickers[m.user.nick] = stickers[5]
	    m.reply "#{m.user.nick} has earned the '#{stickers[5]}' Selfie Sticker!"

	  elsif $selfie_count[m.user.nick] == 7
	    $selfie_stickers[m.user.nick] = stickers[7]
	    m.reply "#{m.user.nick} has earned the '#{stickers[7]}' Selfie Sticker!"

	  elsif $selfie_count[m.user.nick] == 12
	    $selfie_stickers[m.user.nick] = stickers[12]
	    m.reply "#{m.user.nick} has earned the '#{stickers[12]}' Selfie Sticker!"

	  elsif $selfie_count[m.user.nick] == 17
	    $selfie_stickers[m.user.nick] = stickers[17]
	    m.reply "#{m.user.nick} has earned the '#{stickers[17]}' Selfie Sticker!"

	  elsif $selfie_count[m.user.nick] == 29
	    $selfie_stickers[m.user.nick] = stickers[29]
	    m.reply "#{m.user.nick} has earned the '#{stickers[29]}' Selfie Sticker!"

	  # . . .
          end
        else
          $selfie_count[m.user.nick] = 1
          $selfie_stickers[m.user.nick] = stickers[1]
          m.reply "#{m.user.nick} has earned the '#{stickers[1]}' Selfie Sticker!"
        end
      elsif ($selfie == false) && (link.match('imgur.com'))
        m.reply "(#{m.user.nick}) There is no selfie train going on right now ;-;"
      end
    end

    match(/sticker (.+)/, method:  :sticker)
    def sticker(m, nick)
      nick.gsub!(' ', '')
      m.reply "#{nick} currently has the '#{$selfie_stickers[nick]}' sticker." if $selfie_stickers.key? nick
      m.reply "#{nick} doesn't have a Selfie Sticker :(" if !($selfie_stickers.key? nick)
    end

  end
end
