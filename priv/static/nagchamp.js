// /rest/job/google.com/1000
$(function() {
   var success_fn = function(data) {
     console.log("Jobs: "+data)
     $(".panel-body").text(data)
   }

   $('.jobs').click(function() {
     jQuery.ajax("/rest/jobs", { success: success_fn })
   })
})

