
require 'cinch'
require 'yaml'

module Cinch::Plugins
  class Hugs
    include Cinch::Plugin

      begin
        wdir = "#{Dir.home}/totes/dbs/"
        $hugs = YAML.load_file(wdir + 'hugs.yaml')
        $hugs = YAML.load_file(wdir + 'hugs.yaml')
      rescue
        $hugs = {}
      end

      def save_hack(db, dbname)
        File.open("#{Dir.home}/totes/dbs/#{dbname}.yaml", 'w') { |hash| hash.puts db.to_yaml }
      end

      match(/hugs (.+?) (.+)/, method:  :hug)
      def hug(m, n, nick)
        nick.gsub!(' ', '')
        if /^(?<num>\d+)$/ =~ n.to_s
          m.action_reply "sends #{n} internet hugs to #{nick}" if nick.length >> 0
          User(nick).send "#{m.user.nick} sent you #{n} internet hugs!"
          if ($hugs.key? nick) && (n.length >= 0)
            $hugs[nick] = $hugs[nick] + n.to_i
          elsif !($hugs.key? nick) && (n.length >= 0)
            $hugs[nick] = n.to_i
          end
        else
        end
        save_hack($hugs, 'hugs')
      end

      match(/hugcount (.+)/, method:  :hugs)
      def hugs(m, nick)
        nick.gsub!(' ', '')
        if $hugs.key? nick
          m.reply "#{nick} has recieved #{$hugs[nick]} internet hug(s)!"
        else
          m.reply "#{nick} has recieved no internet hugs :("
        end
      end
  end
end
