#!/usr/bin/env ruby

# frozen_string_literal: true

require "irb"

root =  File.join(__dir__, "..")
$LOAD_PATH << File.join(root, "lib")

require "babel"

IRB.setup nil
ARGV.clear # otherwise all script parameters get passed to IRB
IRB.start
