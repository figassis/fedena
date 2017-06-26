#!/bin/bash
irb <<EOF
require 'digest'
require 'securerandom'
password= 'hello'
salt = SecureRandom.hex(4)
hashed_password = Digest::SHA1.hexdigest(salt + password)
puts "#{salt}"
#puts "#{password}"
puts "#{hashed_password}"
EOF
