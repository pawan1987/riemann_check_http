require 'riemann/client'

module RiemannCheckHttp
  class Riemann

    attr_accessor :http_open_timeout
    attr_accessor :http_read_timeout
    attr_accessor :riemann_ttl
    attr_accessor :riemann_con
    
    def initialize(opts = {})
      raise "host: param is missing" if not opts[:host]
      opts[:port] ||= 5555
      opts[:riemann_timeout] ||= 5
      @http_open_timeout = 5
      @http_read_timeout = 30
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
      if url =~ /^(http:\/\/)?((.*?)(\.internal)?\.housing\.com)(\:([0-9]+))?(\/.*)?$/
        if $2
          host = $2
        else
          raise "URL not proper #{url}"
        end
        path = $7 || '/'
        type = $4 ? 'internal' : 'external'
        port = $6 || 80
        app = $3 if $3
      else
          raise "#{url} URL not proper #{url}"
      end
      con = RiemannCheckHttp::NetHttp.new host: host, port: port, read_timeout: 30, open_timeout: 5
      (code, msg) = con.get path
      state = check_app_state code, sc
      send_riemann app, state, type, msg
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

 
#con = RiemannCheckHttp::Riemann.new host:'riemann-host-ip', port: 5555
#res = con.check_http 'test.example.com/path', '501..598', '302..305', '301'
