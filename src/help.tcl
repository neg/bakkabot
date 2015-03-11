namespace eval help {
    proc print {nick host hand chan text} {
        putserv "PRIVMSG $chan :showing $nick some help.."

        lappend help { MM        MM       MM       MM       MM        MM        }
        lappend help {<' \___/| <' \___/|<' \___/|<' \___/|<' \___/| <' \___/|  }
        lappend help {  \_  _/    \_  _/   \_  _/   \_  _/   \_  _/    \_  _/   }
        lappend help {   /  \      /  \     /  \     /  \     /  \      /  \    }
        lappend help { MM                 Some bakkabot help            _][_    }
        lappend help {<' \___/|                                        /___ \   }
        lappend help {  \_  _/       !streck NICK                     |/   \ ,> }
        lappend help {   /  \            Give someone a streck              WW  }
        lappend help {  MM           !strecktop                         _][_    }
        lappend help { <' \___/|         Show most strecked users      /___ \   }
        lappend help {   \_  _/      !strecklist                      |/   \ ,> }
        lappend help {    /  \           Get a streck list                  WW  }
        lappend help {  MM                                              _][_    }
        lappend help { <' \___/|     !poll QUESTION? 1: OPTION ...     /___ \   }
        lappend help {   \_  _/          Create a poll                |/   \ ,> }
        lappend help {    /  \       !vote ID CHOICE                        WW  }
        lappend help {  MM               Give a vote                    _][_    }
        lappend help { <' \___/|     !polls                            /___ \   }
        lappend help {   \_  _/          Get a list of polls          |/   \ ,> }
        lappend help {    /  \       !status ID                             WW  }
        lappend help {  MM               Show poll status               _][_    }
        lappend help { <' \___/|                                       /___ \   }
        lappend help {   \_  _/      !ai blacklist TOPIC              |/   \ ,> }
        lappend help {    /  \           Blacklist a topic                  WW  }
        lappend help {  MM           !ai stupid REASON                  _][_    }
        lappend help { <' \___/|         Forget last opinion           /___ \   }
        lappend help {   \_  _/                                       |/   \ ,> }
        lappend help {    /  \       !agree ID                              WW  }
        lappend help {  MM              Agree to something              _][_    }
        lappend help { <' \___/|     !disagree ID                      /___ \   }
        lappend help {   \_  _/         Disagree to something         |/   \ ,> }
        lappend help {    /  \                                             WW   }
        lappend help {    _][_     _][_     _][_      _][_     _][_     _][_    }
        lappend help {   /___ \   /___ \   /___ \    /___ \   /___ \   /___ \   }
        lappend help {  |/   \ ,>|/   \ ,>|/   \ ,> |/   \ ,>|/   \ ,>|/   \ ,> }
        lappend help {        WW       WW       WW        WW       WW       WW  }

        foreach line $help {
            putserv "PRIVMSG $nick :$line"
        }
    }
}

























