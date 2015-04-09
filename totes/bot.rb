
require 'cinch'
require 'cinch/plugins/identify'
require_relative "lib/cinch/plugins/selfietrain"
require_relative "lib/cinch/plugins/alert"
require_relative "lib/cinch/plugin/PLUGIN GOES HERE"

$admins = ['admin 1', 'admin 2']

# botstuff
bot = Cinch::Bot.new do
  configure do |c|
    c.plugins.plugins = [Cinch::Plugins::Identify, Cinch::Plugins::SelfieTrain, Cinch::Plugins::Alert] # plugins
    c.plugins.prefix = /^./
    c.plugins.options[Cinch::Plugins::Identify] = {
      username: 'NICK',
      password: 'PASSWORD',
      type: :nickserv
    }
    c.server = 'IRC SERVER'
    c.nick = 'NICK'
    c.channels = ['#CHANNEL 1', '#CHANNEL 2']
    c.realname = 'NICK'
    c.user = 'NICK'
  end
  # !
end

bot.start
