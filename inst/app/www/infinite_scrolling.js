$( document ).ready(function() {
 let observer = new IntersectionObserver(function (entries) {
   if (entries[0].intersectionRatio > 0) {
     Shiny.setInputValue("end_vh_reached", true, {priority: "event"});
   }
 });
 observer.observe(document.getElementById("end_vh"));
});
