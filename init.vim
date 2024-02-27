vim9script
import './config/basic_config/init.vim'
import './plugin/plug-install.vim'

import './config/init.vim' as config
config.Setup()
import './builtin_plugin/init.vim' as builtin_plugin
builtin_plugin.Setup()
