require 'net/http'
module RiemannCheckHttp
  class NetHttp
    
    attr_accessor :http
    
    def initialize(opts = {}) 
      raise "host: missing" if not opts[:host]
      opts[:port] ||= 80
      opts[:open_timeout] ||= 5
      opts[:read_timeout] ||= 30
      http = Net::HTTP.new(opts[:host],opts[:port])
      http.open_timeout = opts[:open_timeout]
      http.read_timeout = opts[:read_timeout]
      @http = http
    end
    
    def get(path = '/')
      begin
        res = http.get(path)
        [res.code, res.message]
      rescue Exception => e
        ['598', e.message]
      end
    end

  end 
end


#test
#http = RiemannCheckHttp::NetHttp.new host: 'flatmates.housing.com',port: 80, read_timeout: 30, open_timeout: 5
#puts http.get('/').inspect