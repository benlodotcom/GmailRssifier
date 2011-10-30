require 'gmail' 
require 'sinatra'
require 'builder'
require 'mail'

#Monkey patching of the Message class
class Mail::Message
  
  def content_body
    if self.multipart?
      body = self.html_part ? self.html_part.body : self.text_part.body
    else
      body = self.body                 
    end
  end
  
end
        
class GmailToRss < Sinatra::Base

CONF = YAML.load_file('conf.yml') 

def get_email(feed_abbreviated_name) 
  
#connect to gmail
gmail = Gmail.new(CONF['gmail_username'], CONF['gmail_password'])        
returnedEmails = Array.new()  

#get emails for the corresponding label
gmail.mailbox(CONF['feeds'][feed_abbreviated_name]).emails.take(CONF['email_count']).each do |email| 
  emailCopy = Mail.new do
    subject email.subject
    body  email.content_body.to_s
    date  email.date 
  end
  returnedEmails << emailCopy 
  
end

#logout
gmail.logout

returnedEmails

end
  
get '/feed/:feed_abbreviated_name' do
  @feed_name = CONF['feeds'][params[:feed_abbreviated_name]]
  @mails = get_email(params[:feed_abbreviated_name])
  content_type 'application/rss+xml'
  builder :feed 
end 

end


