
require 'net/http'
require "net/https"
require 'cacert'
require "uri"

module RiemannCheckHttp
  class NetHttp
    
    attr_accessor :open_timeout
    attr_accessor :read_timeout
    attr_accessor :use_ssl
    attr_accessor :use_pem
    attr_accessor :pem_file
    
    def initialize(opts = {}) 
      @use_ssl = opts[:use_ssl] || false
      @use_pem = opts[:use_pem] || false
      @pem_file = opts[:pem_file] || Cacert.pem
      @read_timeout = opts[:read_timeout] || 30
      @open_timeout = opts[:open_timeout] || 10
    end
    
    def get(uri_str)
      begin
        res = fetch(uri_str)
        [res.code, res.message]
      rescue Exception => e
        ['598', e.message]
      end
    end
  
    def fetch(uri_str, limit = 10)
      raise ArgumentError, 'too many HTTP redirects' if limit == 0
      if uri_str =~ /^(http:\/\/|https:\/\/)?(.*)$/
        prot = $1 || 'http://'
        uri_str = "#{prot}#{$2}"
      end
      uri = URI.parse uri_str
      http = Net::HTTP.new uri.host, uri.port
      http.open_timeout = open_timeout
      http.read_timeout = read_timeout
      if use_ssl and (prot == 'https://')
        if use_pem
          http.use_ssl = true
          http.ca_file = pem_file
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        else
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
      else
        http.use_ssl = false
      end
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      case response
      when Net::HTTPSuccess then
        response
      when Net::HTTPRedirection then
        location = response['location']
        #warn "redirected to #{location}"
        fetch(location, limit - 1)
      else
        response
      end
    end

  end 
end

#http = RiemannCheckHttp::NetHttp.new use_ssl: true, use_pem: true, pem_file: '/root/url_monitoring/cacert.pem', open_timeout: 30
#puts http.get('test.example.com').inspect