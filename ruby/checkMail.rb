#!/usr/bin/ruby

require 'net/imap'

conn = Net::IMAP.new('servername', 993, usessl = true, verify=false)
conn.authenticate('LOGIN', 'emailaddress', 'password')

conn.examine('INBOX') 

puts "#{conn.responses["RECENT"]} new messages, #{conn.responses["EXISTS"]} total"

conn.disconnect
