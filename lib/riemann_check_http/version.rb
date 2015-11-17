
require 'json'
require 'open-uri'
require 'open_uri_redirections'
require 'riemann/client'

exclude_apps = ['test', 'backup', 'java', 'nodejs', 'ruby']
$consul_host = '127.0.0.1'
$consul_port = '8500'

#http config
$read_timeout = 30
$open_timeout = 10

#riemann config
$riemann_host = '10.21.1.40'
$riemann_port = '5555'
$riemann_timeout = 5
$riemann_ttl = 120
$riemann_con = ::Riemann::Client.new host: $riemann_host, port: $riemann_port, riemann_timeout: $riemann_timeout


def send_riemann(app, state, type, dsc)
  metric = (state == 'critical') ? 0 : 1
  tuple = {
        service: "#{app}.#{type}",
        state: state,
        tags: ["#{type}_url_monitoring","influxdb"],
        metric: metric,
        description: dsc,
        ttl: $riemann_ttl
  }
  $riemann_con << tuple
end

def open_url(url)
  begin
    res = open(url, open_timeout: $open_timeout, read_timeout: $read_timeout, :allow_redirections => :all)
    res.status
  rescue Exception => e
    ['598', e.message]
  end
end

def check_http(url, *sc)
  if url =~ /^(http:\/\/|https:\/\/)?(.*?)(\.internal)?\.housing\.com/
    app = $2 if $2
    type = $3 ? 'internal' : 'external'
  else
    raise "URL not proper #{url}"
  end
  (code, msg) = open_url url
  state = check_app_state code.to_i, sc
  dsc = msg + ", status code => #{code}"
  #puts app + ','+ state + ',' + type + ',' + dsc
  send_riemann app, state, type, dsc
  [code, msg]
end

# ./check_app_state 303, [400..499, 300, 500..598]
def check_app_state(code, sc)
  state = 'okay'
  unless code.is_a? Integer
    raise "Status code (#{code}) should be integer"
  end
  sc.each do |c|
    if c.is_a? Range
      if (c) === code
        state = 'critical'
        return state
      end
    elsif c.is_a? Integer
      if code == c
        state = 'critical'
        return state
      end
    else
      raise "#{c} is neither Integer nor Range"
    end
  end
  state
end

def list_apps
  begin
    uri = "http://#{$consul_host}:#{$consul_port}/v1/catalog/services"
    response = JSON.parse(open(uri).read)
  rescue Exception => e
    puts "Consul call failed #{e}"
    return []
  end
  apps = {}
  if response['web']
    response['web'].each do |i|
      apps[i] = {}
    end
  end
  apps
end

list_apps.keys.sort.each do |app|
  unless exclude_apps.include?(app)
   check_http "http://#{app}.housing.com", 500..599
   check_http "http://#{app}.internal.housing.com", 500..599
  end
end


