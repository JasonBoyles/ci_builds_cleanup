#!/usr/bin/env ruby
require 'fog'

# a class to delete openstack servers older than a given number of days
class Cleanup
  def servers(older_than = 6, dryrun = true)
    puts 'This is a dryrun.' if dryrun

    # loop over the regions
    %w(IAD DFW HKG SYD).each do |datacenter|
      # Connect to rackspace
      @client = Fog::Compute.new(
        provider: 'rackspace',
        rackspace_username: ENV['RACKSPACE_USERNAME'],
        rackspace_api_key: ENV['RACKSPACE_API_KEY'],
        rackspace_region: datacenter
      )

      now = Time.new
      servers = @client.servers.all.select do |server|
        created_at = Time.parse(server.created)
        server.name =~ /^ci-/ && ((now - created_at) / 3600 > older_than.to_f)
      end

      failed_servers = []

      # Delete them
      servers.each do |server|
        if dryrun == 'true'
          puts "would delete Name : #{server.name}, " \
               "ID: #{server.id}" \
               "created at #{server.created}"
        else
          puts "Deleting Name : #{server.name}, " \
               "ID: #{server.id} " \
               "created at #{server.created}"
          begin
            server.destroy
          rescue
            failed_servers << server
          end
        end
      end
      puts 'Nothing to delete' if servers.empty?
      fail "Failed to delete some servers #{failed_servers.join(',')}" unless
        failed_servers.empty?
    end
  end
end
