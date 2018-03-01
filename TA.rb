#!/bin/env ruby

require 'colorize'
require 'curses'
require 'pathname'

## Set root directory of this script
ROOT = File.dirname(Pathname.new(File.absolute_path(__FILE__)).realpath)

## Set DIR constant with relevant paths
DIR = {
	log: File.join(ROOT, 'log'),
	src: File.join(ROOT, 'src'),
	rb:  File.join(ROOT, 'src/rb')
}

require File.join DIR[:rb], 'handle_argument_parser'

## Get project environment from environment variable or command-line
Env = CL_ARGS[:options][:env] || ENV['TA_ENV'] || 'dev'

if (Env == 'dev')
	## Require development gems
	require 'awesome_print'
	require 'byebug'
end

## Require project files
require File.join DIR[:rb], 'windows'
require File.join DIR[:rb], 'main'

