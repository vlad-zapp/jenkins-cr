require "option_parser"
require "http/client"
require "json"

class JenkinsCommunication
  def initialize(@uri : URI, @user : String, @token : String)
  end

  def api_request(path : String, accepted_codes : Array(Int32) = [200], pretty : Bool = false)
    client = HTTP::Client.new(@uri)
    client.basic_auth(@user, @token)
    path = "#{normalize_path(path)}/api/json"
    response = client.get(path)
    unless accepted_codes.includes?(response.status_code)
      raise "Unexpected http code: #{response.status_code}"
    end
    return pretty \
      ? JSON.parse(client.get(path).body).to_pretty_json
      : client.get(path).body
  end

  def normalize_path(path : String)
    if path.strip("/") == ""
      return "/"
    end
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
  address, user, token, action = ARGV[0..3]
  parameters = ARGV[4..-1]
else
  puts parser
  exit 1
end

comm = JenkinsCommunication.new(URI.parse(address), user, token)

case
when action=="get" && parameters.size==1
  puts comm.api_request(parameters.first? || "/", pretty: flags.includes?("p"))
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
