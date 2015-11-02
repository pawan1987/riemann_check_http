require 'riemann/client'
require 'cacert'
require_relative 'net_https'

module RiemannCheckHttp
  class Riemann

    attr_accessor :http_open_timeout
    attr_accessor :http_read_timeout
    attr_accessor :riemann_ttl
    attr_accessor :riemann_con
    attr_accessor :use_ssl
    attr_accessor :use_pem #http.verify_mode = OpenSSL::SSL::VERIFY_NONE if use_pem = false
    attr_accessor :pem_file #if not defined takes Cacert.pem file coming through Cacert ruby gem
    
    def initialize(opts = {})
      raise "host: param is missing" if not opts[:host]
      opts[:port] ||= 5555
      opts[:riemann_timeout] ||= 5
      @http_open_timeout = 10
      @http_read_timeout = 30
      @use_ssl = opts[:use_ssl] || false
      @use_pem = opts[:use_pem] || false
      @pem_file = opts[:pem_file] || Cacert.pem
      @riemann_ttl = 120
      @riemann_con = ::Riemann::Client.new host: opts[:host], port: opts[:port], riemann_timeout: opts[:riemann_timeout]
    end
    
    
    def send_riemann(app, state, type, dsc)
      metric = (state == 'critical') ? 0 : 1
      tuple = {
            service: "#{app}.#{type}",
            state: state,
            tags: ["#{type}_url_monitoring","influxdb"],
            metric: metric,
            description: dsc,
            ttl: riemann_ttl
      }
      riemann_con << tuple
    end
    
    def check_http(url, *sc)
      code = '501'
      msg = 'Unknown'
      if url =~ /^(http:\/\/|https:\/\/)?(.*?)(\.internal)?\.housing\.com/
        app = $2 if $2
        type = $3 ? 'internal' : 'external'
      else
        raise "Improper url: #{url}"
      end
      con = RiemannCheckHttp::NetHttp.new use_pem: use_pem, use_ssl: use_ssl, read_timeout: 30, open_timeout: 5, pem_file: pem_file
      (code, msg) = con.get url
      state = check_app_state code, sc
      dsc = msg + ", status code #{code}"
      send_riemann app, state, type, dsc
      [code, msg]
    end
    
    def check_app_state(code, sc)
      state = 'okay'
      sc.each do |c|
        if c =~ /^[0-9]{3}(\.\.[0-9]{3})?$/
          if $1
            if eval(c) === code.to_i
              state = 'critical'
              break
            end
          else
            if code.to_s == c
              state = 'critical'
              break
            end
          end
        else
          raise "#{c.inspect} status code is not in valid format"
        end
      end
      state
    end
  
  end  
  
end

 
#con = RiemannCheckHttp::Riemann.new host:'x.x.x.x', port: 5555, use_ssl: true, use_pem: true
#res = con.check_http 'test.example.com', '501..598', '302..305', '301'
#puts res.inspect
