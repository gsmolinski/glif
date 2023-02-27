$( document ).ready(function() {
 Shiny.addCustomMessageHandler("get_geolocation", function(arrrr) {
   navigator.geolocation.getCurrentPosition(success);

   function success(pos) {
     Shiny.setInputValue("geolocation_lat", pos.coords.latitude, {priority: "event"});
     Shiny.setInputValue("geolocation_lng", pos.coords.longitude, {priority: "event"});
   }
 });
});
