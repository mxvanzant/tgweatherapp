require 'json'
require 'rf-rest-open-uri'
require 'rest-client'
require 'date'

class ApiController < ApplicationController
  $forecast_data_cache = Hash.new
  
  def getforecasttest
    apikey = params[:apikey]
    zip = params[:zip].strip
    data = get_default_forecast_data(zip)
    data["source"] = "railstest"
    data["apikey"] = apikey
    #pjson = JSON.pretty_generate(data)
    render :json => data
  end
  
  def getforecast
    apikey = params[:apikey]
    zip = params[:zip].strip
    data = nil
    
    if apikey == "myapikey"
      if is_valid_zip? zip
        data = get_forecast_data(zip)
        data["apikey"] = apikey
      else
        data = get_default_forecast_data(zip)
        data["source"] = "error"
        data["apikey"] = apikey
        data["error"] = "Please make sure you have entered a 5 digit zip code. For example:\n\n60090"
      end
    else
      sleep(3)
      data = get_default_forecast_data(zip)
      data["source"] = "error"
      data["error"] = "Your API Key of #{apikey} was incorrect.\n\nHint: try \"myapikey\" without the quotes."
      data["apikey"] = ""
    end
    render :json => data
  end

  def is_valid_zip?(zip)
    if (zip =~ /^\d{5}$/) == 0
      return true
    end
    false
  end

  def get_forecast_data(zip)
    # if allowed cache size is exceeded, truncate the cache!
    if $forecast_data_cache.length > 1000
      $forecast_data_cache = Hash.new
    end
    
    data = get_forecast_data_cached(zip)
    
    if data.nil?
      data = get_forecast_data_remote(zip)
      $forecast_data_cache[zip] = data
    end
    
    return data
  end

  def get_forecast_data_cached(zip)
    data = $forecast_data_cache[zip]
    
    if data.nil?
      return data
    end
    
    # is old? then delete it
    seconds = Time.now - data["timestamp"]
    if seconds > 60
      $forecast_data_cache.delete(zip)
      return nil
    end
    
    data["source"] = "cache"
    return data
  end
    
  def get_forecast_data_remote(zip)
    result = RestClient.get "http://api.wunderground.com/api/bcad800b25943bd3/forecast/q/#{params[:zip]}.json"
    puts "result:"
    puts result
    hash = JSON.parse(result)
    
    error = hash["response"]["error"]
    if error.nil?
      hash = hash["forecast"]["txt_forecast"]
      hash["forecastday"].pop until hash["forecastday"].length == 6
      hash["zip"] = zip
      hash["timestamp"] = Time.now
      hash["source"] = "remote"
      hash["error"] = ""
      return hash
    end
    
    hash = get_default_forecast_data(zip)
    hash["source"] = "remote"
    hash["error"] = error["description"] + "\n\nMaybe try a different zip code?"
    return hash
  end
  
  def get_default_forecast_data(zip)
    hash = Hash.new
    time = Time.now
    hash["forecastday"] = []
    hash["zip"] = zip
    hash["timestamp"] = time
    hash["date"] = time.strftime("%l:%M %P %Z").strip.downcase
    hash["source"] = "default"
    hash["error"] = ""
    return hash
  end
end
