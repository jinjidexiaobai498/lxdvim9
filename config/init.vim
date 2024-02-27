vim9script

import './basic_plugin_config/init.vim' as basic_plugin_config
import './extend_plugin_config/init.vim' as extend_plugin_config
import './builtin_plugin_config/init.vim' as builtin_plugin_config

export def Setup()
    basic_plugin_config.Setup()
    extend_plugin_config.Setup()
    builtin_plugin_config.Setup()
enddef
