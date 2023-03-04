$( document ).ready(function() {
 Shiny.addCustomMessageHandler("get_geolocation", function(arrrr) {
   const options = {
     enableHighAccuracy: true
   };

   function success(pos) {
     Shiny.setInputValue("geolocation_lat", pos.coords.latitude, {priority: "event"});
     Shiny.setInputValue("geolocation_lng", pos.coords.longitude, {priority: "event"});
   }

  function error(err) {}

   navigator.geolocation.getCurrentPosition(success, error, options);
 });
});
