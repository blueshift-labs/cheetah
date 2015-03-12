require 'cheetah/message'
require 'cheetah/exception'
require 'cheetah/messenger/messenger'
Dir["#{File.dirname(__FILE__)}/cheetah/messenger/*.rb"].each {|f| require f}

module Cheetah
  class Cheetah

    UNSUB_REASON = {
      'a'	=> 'abuse complaint',
      'b'	=> 'persistent bounces',
      'd'	=> 'deleted via admin interface',
      'e'	=> 'email to remove address (from mailing)',
      'i'	=> 'request via api',
      'k'	=> 'bulk unsubscribe',
      'r'	=> 'request in reply to mailing',
      'w'	=> 'web-based unsubscribe (link from mailing)',
    }

    # options hash example (all fields are required, except whitelist_filter):
    # {
    #   :host             => 'ebm.cheetahmail.com'
    #   :username         => 'foo_api_user'
    #   :password         => '12345'
    #   :aid              => '67890'                  # the 'affiliate id'
    #   :whitelist_filter => //                       # if set, emails will only be sent to addresses which match this pattern
    #   :enable_tracking  => true                     # determines whether cheetahmail will track the sending of emails for analytics purposes
    #   :messenger        => Cheetah::ResqueMessenger
    # }
    def initialize(options)
      @messenger = options[:messenger].new(options)
    end

    def send_email(eid, email, params = {})
      path = "/ebm/ebmtrigger1"
      params['eid']   = eid
      params['email'] = email
      @messenger.send_message(Message.new(path, params))
    end
    
    #Create subscriber list
    def set_subscriber_list(params = {})
      path = "/cgi-bin/api/setlist1"
      response = @messenger.do_request(Message.new(path, params))
      response.body.match(/\d{1,12}/)[0]
    end
    
    #Create new mailing
    #Send mail set parameter {"approve" => 1, "send" => 1}
    #Test send set parameter {"test" => 8, "tester" => "test@example.com"}
    def mailgo(params = {})
      path = "/cgi-bin/api/mailgo1"
      response = @messenger.do_request(Message.new(path, params))
      response.body.match(/\d{1,12}/)[0]
    end
    
    #Set Mail - upload content for a mailing
    #Create maling template using valid parameter
    def setmail(params = {})
      path = "/cgi-bin/api/setmail1"
      @messenger.send_message(Message.new(path, params))
    end
    
    #Send bulkmail
    #Create maling template using valid parameter or set mid
    #Send mailing set parameter {"approve" => 1, "send" => 1}
    #Test send set parameter {"test" => 8, "tester" => "test@example.com"}
    def bulkmail(params = {})
      path = "/api/bulkmail1"
      response = @messenger.do_request(Message.new(path, params))
      response.body.match(/\d{1,12}/)[0]
    end

    def mailing_list_update(email, params = {})
      path = "/api/setuser1"
      params['email'] = email
      @messenger.send_message(Message.new(path, params))
    end

    def mailing_list_email_change(oldemail, newemail)
      path = "/api/setuser1"
      params             = {}
      params['email']    = oldemail
      params['newemail'] = newemail
      @messenger.send_message(Message.new(path, params))
    end
    
    #export users in subscriber list
    #provide user emails in csv file and upload on cheetahmail
    def load(filepath, params = {})
      path = "/cgi-bin/api/load1"
      file = File.open(filepath)
      params["file"] = UploadIO.new(file, "text/csv", filepath.split("/").last)
      @messenger.load_data(Message.new(path, params))
    end
  end
end
