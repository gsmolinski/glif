$( document ).ready(function() {
 let observer = new IntersectionObserver(function (entries) {
   if (entries[0].isIntersecting) {
     Shiny.setInputValue("end_vh_reached", true, {priority: "event"});
   }
 });
 observer.observe(document.getElementById("end_vh"));

 Shiny.addCustomMessageHandler("trigger_end_vh_reached", function(placeholder) {
   Shiny.setInputValue("end_vh_reached", true, {priority: "event"});
 });
});
