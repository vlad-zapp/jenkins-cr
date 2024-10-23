require "option_parser"
require "http/client"
require "json"

class JenkinsCommunication
  def initialize(@host : String, @port : Int32, @user : String, @token : String)
  end

  def api_request(path : String, pretty : Bool = false)
    client = HTTP::Client.new(@host, @port)
    client.basic_auth(@user, @token)
    path = "#{normalize_path(path)}/api/json"
    return pretty \
      ? JSON.parse(client.get(path).body).to_pretty_json
      : client.get(path).body
  end

  def normalize_path(path : String)
    return "/job/" + path.strip("/").split("/").join("/job/")
  end
  
end

flags = [] of String

parser = OptionParser.new do |opts|
  opts.banner = "Usage: jenkins-cr <address> <user> <token> <action> [parameters] [flags]"
  opts.on("-p", "--pretty", "Output prettified json") do
    flags << "p"
  end
end
parser.parse

if ARGV.size >= 4
  host, port = ARGV[0].split(":").try { |x| {x[0],(x.size>1 ? x[1].to_i: 8080)} }
  user, token, action = ARGV[1..3]
  parameters = ARGV[4..-1]
else
  puts parser
  exit 1
end

comm = JenkinsCommunication.new(host, port, user, token)

case
when action=="get" && parameters.size==1
  puts comm.api_request(parameters.first? || "/", flags.includes?("p"))
else
  puts parser
  exit 1
end


# puts host, port, user, token, action
# puts parameters

# if response.status_code == 200
#   puts response.body
# else
#   puts "Error: HTTP code #{response.status_code}"
# end
