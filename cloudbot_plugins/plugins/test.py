# This is just a placeholder

from cloudbot import hook

@hook.command()
def test(nick, notice):
    notice('this is a test')
