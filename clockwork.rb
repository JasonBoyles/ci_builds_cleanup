require 'clockwork'
require_relative 'cleanup'

# Module for clockwork to import to do our periodic jobs.
module Clockwork
  handler do |job|
    puts "Running #{job}"
    Cleanup.new.servers(6, false)
  end

  every(1.hour, 'hourly.job')
end
