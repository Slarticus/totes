require 'cinch'
require 'cinch/plugins/identify'
require_relative "lib/cinch/plugins/uno/uno"

# botstuff
bot = Cinch::Bot.new do
  configure do |c|
    c.plugins.plugins = [Cinch::Plugins::Identify, Cinch::Plugins::Uno]
    c.plugins.prefix = /^./
    c.plugins.options[Cinch::Plugins::Identify] = {
      username: 'NICK',
      password: 'PASSWORD',
      type: :nickserv
    }
    c.server = 'SERVER'
    c.nick = 'NICK'
    c.channels = ['#CHANNEL']
    c.realname = 'NICK'
    c.user = 'NICK'
  end
  # !
end

bot.start
