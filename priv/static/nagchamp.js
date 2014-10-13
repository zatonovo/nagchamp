// /rest/job/google.com/1000
function load_jobs() {
   var success_fn = function(data) {
     console.log("Jobs: "+data)
     var arr = jQuery.parseJSON(data)
     arr.map(add_job)
   }

   jQuery.ajax("/rest/jobs", { success: success_fn })
}

function add_job(job_id) {
  $(".jobs").append('<div class="row job-'+job_id+'">')
  $(".jobs .job-"+job_id).append('<div class="col-md-8">'+job_id+'</div>')
  $(".jobs .job-"+job_id).append('<div class="col-md-4"><button>Stop</button></div>')
  $(".jobs button").click(function(e) {
    jQuery.ajax("/rest/job/"+job_id)
  })
}

$(function() {
   load_jobs()

   var success_fn = function(job_id) {
     console.log("Added job: "+job_id)
     add_job(job_id)
   }

   $('.job-submit').click(function() {
     var url = $(".job-url").val()
     var delay = $(".job-delay").val()
     jQuery.ajax("/rest/job/"+url+"/"+delay, { success: success_fn })
   })
})

