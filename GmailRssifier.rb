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
    gmail.mailbox(feed_name).emails.take(CONF['email_count']).each do |email| 

      emailData = {
        :subject => email.subject,
        :body => email.content_body.to_s
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
    feed_name = CONF['feeds'][params[:feed_abbreviated_name]]
    feed_name = feed_name ? feed_name : params[:feed_abbreviated_name]
    # builder parameters 
    @feed_name = feed_name
    @mails = get_email(@feed_name) 
    # response
    content_type 'application/rss+xml'
    builder :feed 
  end 

end

# Monkey patching of the Message class so that it returns the body
# of the content part of the email
class Mail::Message

  def content_body
    if self.multipart?
      body = self.html_part ? self.html_part.body : self.text_part.body
    else
      body = self.body                 
    end
  end

end


