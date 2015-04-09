# lib/cinch/plugins/alert.rb

require 'cinch'

module Cinch::Plugins
  class Alert
    include Cinch::Plugin
    
    match(/alert (.+)/, method:  :alert)
    def alert(m, string)
      if $admins.include? m.user.nick
        m.reply Format(:red, :bold, :italic, :underline, 'ATTENTION: ' + string.upcase + '!')
      else
      end
      
    end
  end
end

