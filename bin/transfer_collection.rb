#!/usr/bin/env ruby

# frozen_string_literal: true

require "colored2"
require "optparse"

$LOAD_PATH << File.expand_path(File.join(__dir__, "..", "lib"))

require "babel"

options = {}
op = OptionParser.new do |opt|
  opt.on("--all") { |o| options[:all] = true }
  opt.on("--from OWNER", String) { |o| options[:from] = o }
  opt.on("--to OWNER", String) { |o| options[:to] = o }
  opt.on("--save") { |o| options[:save] = 1 }
  opt.on("--verbose") { |o| options[:verbose] = o }
end
# TODO: set op.banner

begin
  op.parse!
rescue OptionParser::InvalidOption => e
  puts "Invalid Option: #{e}".red
  puts op.banner
  exit 1
end

transfer = Babel::Operation::TransferCollection.new(
  from: options[:from],
  to: options[:to],
  all: options[:all],
  collections: ARGV
)

if transfer.candidates.count.zero?
  puts "No collection ids found or provided. Exiting.".red
  exit 0
end

# TODO: may want to allow these to be reported without bailing out.
if transfer.unknown_collections.count.positive?
  puts "Unknown collections #{transfer.unknown_collections}".red.bold
  exit 1
end

if transfer.restricted_collections.count.positive?
  puts "Collections not owned by #{options[:from]}: #{transfer.restricted_collections}".red.bold
  exit 1
end

puts "Collections with pending transfers (to be skipped):"
transfer.pending_collections.sort.each do |coll|
  "  #{coll}".blue
end

if transfer.allowed_collections.count.zero?
  puts "No collections available for transfer.".red
  exit 0
end

puts "Collections to be processed:"
transfer.allowed_collections.sort.each do |coll|
  "  #{coll}".green
end

puts "Proposed mb_transfer:"
puts "  SUBMITTER: " + transfer.mb_transfer.submitter.yellow.bold
puts "  SUBMITTER_USERNAMES: "
transfer.mb_transfer.submitter_usernames.each do |username|
  puts "    " + username.yellow.bold
end
puts "  RECEIVER: " + transfer.mb_transfer.receiver.yellow.bold
puts "  COLLECTIONS:"
transfer.mb_transfer.payload.each do |collid|
  puts "    " + collid.to_s.bold
end


if options[:save]
  token = transfer.run!
  puts "TOKEN: #{transfer.token}"
  link = "https://babel.hathitrust.org/cgi/mb/transfer/complete/#{transfer.token}"
  puts "LINK: #{link.green}"
end
