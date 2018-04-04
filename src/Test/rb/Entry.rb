
### Unit Tests Entry Point

require 'minitest/pride'
require 'minitest/autorun'

## Require Test preparation files
require_files DIR[:test][:rb], except: 'Entry'
## Require Unit Test files
require_files File.join(DIR[:test][:rb], 'Tests')
require_files File.join(DIR[:test][:rb], 'Tests/Input')
require_files File.join(DIR[:test][:rb], 'Tests/Savefile')

