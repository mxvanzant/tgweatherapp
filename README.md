# tgweatherapp
A simple Angular/Ruby app for showing a three day weather forecast.

This initial version is using a Sinatra back end. I used Sinatra since it was super easy to setup so I could concentrate on the Angular front end. It's been quite a while since I've done any Rails and even then it was not much :) Next, I'll transfer/transform the back end code from Sinatra to Rails.

Just added the Rails version.

In either case (Sinatra or Rails) be sure and add "gem 'thin'" to your Gemfile. There was a problem running on Webrick with one of the modules I required (can't remember which one, maybe rest-client).

About the App:
  I created an ng directive to validate the zip code (could have also used the ng-pattern directive.)

  On the top bar I display the current zip code, the time from wunderground and whether the data was served remote (from wunderground) or from cache.

  Data from wunderground is cached for 60 seconds max. The cache size limit is 1000 unique zip codes. If it reaches that size it is truncated. (For a real app I would use some kind of algorithm that would just get rid of the oldes entries to maintain a max cache size.) Also, it might make sense to use memcached or something like that...

  Also, this app requires an API key which is defaulted in the prompt box. This could be stored in local storage or a cookie (not implemented).

I'm using Ruby 2.2.0.

Try it out! :)



