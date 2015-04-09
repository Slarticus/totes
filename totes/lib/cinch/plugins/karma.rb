
require 'cinch'
require 'yaml'

module Cinch::Plugins
  class Karma
    include Cinch::Plugin
    
    begin
	wdir = "#{Dir.home}/totes/dbs/"
	$upvotes = YAML.load_file(wdir + 'upvotes.yaml')
    rescue
	$upvotes = {}
    end

    def save_hack(db, dbname)
	    File.open("#{Dir.home}/totes/dbs/#{dbname}.yaml", 'w') { |hash| hash.puts db.to_yaml }
    end

    def karmasort
      buffer = $upvotes.first(3)
      top = [(buffer[0]), (buffer[1]), (buffer[2])]
      top.join(', ')
    end

    match(/upvote (.+)/ , method:  :upvote)
    def upvote(m, nick)
      nick.gsub!(' ', '')
      if m.user.nick == nick
        m.reply "(#{m.user.nick}) You can't upvote yourself!"
      elsif nick.length > 0
        m.reply "#{m.user.nick} gave #{nick} one useless internet point! hooray!"
        User(nick).send "#{m.user.nick} gave you one useless internet point!"
        if $upvotes.key? nick
          $upvotes[nick] = $upvotes[nick] + 1
        elsif !($upvotes.key? nick)
          $upvotes[nick] = 1
        end
      end
      save_hack($upvotes, 'upvotes')
    end

    match(/downvote (.+)/ , method:  :downvote)
    def downvote(m, nick)
      nick.gsub!(' ', '')
      if m.user.nick == nick
        m.reply "(#{m.user.nick}) You can't downvote yourself!"
      elsif nick.length > 0
        m.reply "#{m.user.nick} forcefully took one useless internet point from #{nick}! onoes!"
        User(nick).send "#{m.user.nick} took one useless internet point away from you D:"
        if ($upvotes.key? nick)
          $upvotes[nick] = $upvotes[nick] - 1
        elsif !($upvotes.key? nick)
          $upvotes[nick] = 0
        end
      end
      save_hack($upvotes, 'upvotes')
    end

    match(/karma (.+)/ , method:  :karma)
    def karma(m, nick)
      nick.gsub!(' ', '')
      if $upvotes.key? nick
        m.reply "#{nick} has #{$upvotes[nick]} karma."
      elsif nick.downcase == 'top'
        m.reply "Top three fake internet point accumulators: #{karmasort}"
      else
        m.reply "#{nick} has no karma."
      end
    end
  end
end
