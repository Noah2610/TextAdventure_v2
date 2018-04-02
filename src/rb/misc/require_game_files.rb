### Require Game Files
## curses windows - window manager
require File.join DIR[:windows],   'Manager'

## Input stuff
require File.join DIR[:input],     'Input'
require File.join DIR[:input],     'Line'
require File.join DIR[:input],     'Words'

#TODO: Clean up
module Saves end
## Methods for saving and loading objects
require_files File.join(DIR[:includes], 'SaveMethods')
#require File.join DIR[:includes],  'Savable'
## Includes (Inventory, Keywords, Savable)
require_files DIR[:includes] #, except: 'Savable'

## Verbs
require File.join DIR[:verbs],     'Verb'
require_files DIR[:verbs], except: 'Verb'

## Terms
require File.join DIR[:terms],     'Term'

## Events
require File.join DIR[:events],    'Event'

## Instances (Items, Persons, Rooms, Components)
require File.join DIR[:instances], 'Instance'

## Savefile
require File.join DIR[:rb],        'Savefile'

## Player
require File.join DIR[:rb],        'Player'
