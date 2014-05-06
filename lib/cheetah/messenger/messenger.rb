require 'net/http'
require 'net/https'
require 'uri'

module Cheetah
  class Messenger

    def initialize(options)
      @options  = options
      @cookie   = nil
    end

    # determines if and how to send based on options
    # returns true if the message was sent
    # false if it was suppressed
    def send_message(message)
      if !@options[:whitelist_filter] or message.params['email'] =~ @options[:whitelist_filter]
        message.params['test'] = "1" unless @options[:enable_tracking]
        do_send(message) # implemented by the subclass
        true
      else
        false
      end
    end

    # handles sending the request and processing any exceptions
    def do_request(message)
      begin
        login unless @cookie
        initheader = {'Cookie' => @cookie || ''}
        message.params['aid'] = @options[:aid]
        resp = do_post(message.path, message.params, initheader)
      rescue CheetahAuthorizationException => e
        # it may be that the cookie is stale. clear it and immediately retry. 
        # if it hits another authorization exception in the login function then it will come back as a permanent exception
        @cookie = nil
        retry
      end
    end

    private #####################################################################

    # actually sends the request and raises any exceptions
    def do_post(path, params, initheader = nil)
      http              = Net::HTTP.new(@options[:host], 443)
      http.read_timeout = 10
      http.use_ssl      = true
      if(@options[:host].start_with?("trig."))
        http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
      else
        http.verify_mode  = OpenSSL::SSL::VERIFY_PEER
      end

      request = Net::HTTP.Post.new(path, initheader)
      request.set_form_data(params)

      resp = http.request(request)

      raise CheetahTemporaryException,     "failure:'#{path}?#{data}', HTTP error: #{resp.code}"            if resp.code =~ /5../
      raise CheetahPermanentException,     "failure:'#{path}?#{data}', HTTP error: #{resp.code}"            if resp.code =~ /[^2]../
      raise CheetahAuthorizationException, "failure:'#{path}?#{data}', Cheetah error: #{resp.body.strip}"   if resp.body =~ /^err:auth/
      raise CheetahTemporaryException,     "failure:'#{path}?#{data}', Cheetah error: #{resp.body.strip}"   if resp.body =~ /^err:internal error/
      raise CheetahPermanentException,     "failure:'#{path}?#{data}', Cheetah error: #{resp.body.strip}"   if resp.body =~ /^err/
                                                                                                            
      resp                                                                                                  
    end

    # sets the instance @cookie variable
    def login
      begin
        log_msg = "(re)logging in-----------"
        path = "/api/login1"
        params              = {}
        params['name']      = @options[:username]
        params['cleartext'] = @options[:password]
        @cookie = do_post(path, params)['set-cookie']
      rescue CheetahAuthorizationException => e
        raise CheetahPermanentException, "authorization exception while logging in" # this is a permanent exception, it should not be retried
      end
    end

  end
end
