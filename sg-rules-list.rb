#! /usr/bin/env ruby
require 'json'

# CSV header
puts "GroupId,GroupName,Description,Kind,protocol,port,IPrange"

# Get SecurityGroups list
str = `aws ec2 describe-security-groups`
sghash = JSON.load(str);

# Output ALL SecurityGroups
sghash["SecurityGroups"].each do |sg|
  sgname = "\"" + sg["GroupId"] + "\",\"" + sg["GroupName"] + "\",\"" + sg["Description"] + "\""

  # outbound rules
  unless sg["IpPermissionsEgress"].empty? then
    sg["IpPermissionsEgress"].each do |outboundrule|
      obprotocol = outboundrule["IpProtocol"].to_s
      obport = outboundrule["FromPort"].to_s + "-" + outboundrule["ToPort"].to_s
      outboundrule["IpRanges"].each do |cidr|
        puts sgname + ",\"outbound\",\"" + obprotocol + "\",\"" + obport + "\",\"" + cidr["CidrIp"] + "\""
      end
    end
  end

  # inbound rules
  unless sg["IpPermissions"].nil? then
    sg["IpPermissions"].each do |inboundrule|
      ibprotocol = inboundrule["IpProtocol"].to_s
      ibport = inboundrule["FromPort"].to_s + "-" + inboundrule["ToPort"].to_s
      unless inboundrule["IpRanges"].empty? then
        inboundrule["IpRanges"].each do |iplist|
          puts sgname + ",\"inbound\",\"" + ibprotocol + "\",\"" + ibport + "\",\"" + iplist["CidrIp"] + "\""
        end
      end
      unless inboundrule["UserIdGroupPairs"].empty? then
        inboundrule["UserIdGroupPairs"].each do |uglist|
          puts sgname + ",\"inbound\",\"" + ibprotocol + "\",\"" + ibport + "\",\"" + uglist["GroupId"] + "\""
        end
      end
    end
  end

end

