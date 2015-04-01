(function(){
  var app = angular.module('tgweatherapp', []);
  
  var db = {
    data: {
      date: "",
      forecastday: [],
      zip: "",
      timestamp: "",
      source: ""
    }
  };

  app.controller('ForecastController', function(){
    this.db = db;
    
    this.getHeader = function(){
      if (this.db.data.date == "")
        return "";
      return ": " + this.db.data.zip + " @ " + this.db.data.date.toLowerCase() + " from " + this.db.data.source;
    };
  });
  
  app.controller('ZipController', ['$http', function($http){
    var zipcontroller = this;
    this.zip = "";
    this.apikey = null;
    this.isLoading = false;
    
    this.alert = function(){
      alert("Please make sure you have entered a 5 digit zip code. For example:\n\n60090");
    }

    this.getForecast = function(forecast){
      if(!this.apikey)
        this.apikey = prompt("Please enter your assigned API key.", "myapikey");
      if(!this.apikey)
        this.apikey = "invalid"
      this.isLoading = true;
      $http.get('/api/' + this.apikey.trim() + '/weather/zip/' + this.zip).
        success(function(data){
          forecast.db.data = data;
          if (data.error.length > 0){
            if (data.apikey.length == 0)
              zipcontroller.apikey = null;
            alert(data.error);
          }
          zipcontroller.isLoading = false;
        }).
        error(function(data, status, headers, config, statusText){
          alert("Server Error:\n\nHTTP Status " + status + "\n\n" + statusText);
          zipcontroller.isLoading = false;
        });
    };
  }]);
  
  app.directive('forecastDay', function(){
    return {
      restrict: 'E', //E for element.
      templateUrl: 'forecast-day.html'
    };
  });
  
  app.directive('validZipcode', function(){
    return {
      require: 'ngModel',
      restrict: 'A',
      link: function(scope, elm, attrs, ctrl){
        var regex = /^\d{5}$/
        ctrl.$parsers.unshift(function(viewValue){
          if(regex.test(viewValue))
            ctrl.$setValidity('validZipcode', true);
          else
            ctrl.$setValidity('validZipcode', false);
          return viewValue;
        });
      }
    };
  });
  
})();

