### Require Game Files
## curses windows - window manager
require File.join DIR[:windows],   'Manager'

## Input stuff
require File.join DIR[:input],     'Input'
require File.join DIR[:input],     'Line'
require File.join DIR[:input],     'Words'

## Keywords
require File.join DIR[:rb],        'Keywords'

## Inventory
require File.join DIR[:rb],        'Inventory'

## Verbs
require File.join DIR[:verbs],     'Verb'
require_files DIR[:verbs], except: 'Verb'

## Terms
require File.join DIR[:terms],     'Term'

## Events
require File.join DIR[:events],    'Event'

## Instances (Items, Persons, Rooms, Components)
require File.join DIR[:instances], 'Instance'

## Player
require File.join DIR[:rb],        'Player'
