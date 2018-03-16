
### Unit Tests Entry Point

require 'minitest/pride'
require 'minitest/autorun'

## Require Unit Tests
require_files DIR[:tests], except: 'Entry'

