#!/usr/bin/env ruby

require 'gmail' 
require 'sinatra'
require 'builder'
require 'mail'

class GmailRssifier < Sinatra::Base

  # Configuration loading from the conf.yml file
  CONF = YAML.load_file('conf/conf.yml') 

  def get_email(feed_name) 

    # Connect to gmail
    gmail = Gmail.new(CONF['gmail_username'], CONF['gmail_password'])
           
    returnedEmails = Array.new()  

    # Get the first n emails for a certain label and copy them in an array
    gmail.mailbox(feed_name).emails(:after => Date.today - CONF['nb_days']).each do |email| 
      
      content_part = email.content_part
      emailData = {
        :subject => email.subject,
        # The mail library returns wrong encodings, workaround to solve the problem
        # Might be solved with future releases of the mail library
        :body => email.content_part.body.to_s.force_encoding(email.content_part.charset),
        :date => email.date        
      }

      returnedEmails << emailData
    end

    # Disconnect from gmail
    gmail.logout

    returnedEmails

  end

  get '/feed/:feed_abbreviated_name' do
    # Tries to match the feed_abbreviated_name with one specified in conf.yml
    # if it finds one, load the content for the associated label
    # otherwise fall back to loading the content of a label having the same name as the abbreviated name
    feed_name = CONF['feeds'] ? CONF['feeds'][params[:feed_abbreviated_name]] : nil
    feed_name = feed_name ? feed_name : params[:feed_abbreviated_name] 
    # builder parameters 
    @feed_name = feed_name
    @feed_url = request.url
    @mails = get_email(@feed_name) 
    # response
    content_type 'application/rss+xml'
    builder :feed 
  end 

end

# Monkey patching of the Message class so that it returns
# the content part of the email
class Mail::Message
  
  def content_part 
    if self.multipart?
      self.html_part ? self.html_part : self.text_part 
    else
      self                
    end
  end

end


