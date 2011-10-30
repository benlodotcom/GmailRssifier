# GmailRssifier
GmailRssifier is a small Sinatra application allowing you to generate RSS feeds from labeled emails in your gmail account.

GmailRssifier was created because I was willing to read my newsletters in my favorite RSS reader. Gmail offers an RSS feed for your emails, however the content is truncated and I didn't want that, therefore this very small and simple Sinatra app.

# Install

## Configuration

* Open conf.sample.yml.
* Fill in your information.
* Rename conf.sample.yml to conf.yml and you're good to go.

## Start it

* ``bundle install`` to get the required dependencies.
* ``rackup`` to startup the application.              
* You can now access your RSS feeds through ``http://yourdomain:port/feed/feed_abreviated_name``

# Deploy it on a remote server

I'm personally using [Heroku](http://www.heroku.com/ "heroku") to host my instance of GmailRssifier, but any host supporting rack applications should do the trick !
