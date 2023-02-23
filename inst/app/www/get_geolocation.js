$( document ).ready(function() {
 Shiny.addCustomMessageHandler("get_geolocation", function(arrrr) {
   navigator.geolocation.getCurrentPosition(success, error);

   function error(err) {
     Shiny.setInputValue("geolocation", false, {priority: "event"});
   }

   function success(pos) {
     Shiny.setInputValue("geolocation", true, {priority: "event"});
     Shiny.setInputValue("geolocation_lat", pos.coords.latitude, {priority: "event"});
     Shiny.setInputValue("geolocation_lng", pos.coords.longitude, {priority: "event"});
   }
 });
});
