// /rest/job/google.com/1000
function load_jobs() {
   var success_fn = function(data) {
     console.log("Jobs: "+data)
     var arr = jQuery.parseJSON(data)
     arr.map(display_job)
   }

   jQuery.ajax("/rest/jobs", { success: success_fn })
}

function display_job(job_id, url, delay, type) {
  $(".jobs").append('<div class="row job-'+job_id+'">')
  $(".jobs .job-"+job_id)
    .append('<div class="col-md-2">'+job_id+'</div>')
    .append('<div class="col-md-2">'+type+'</div>')
    .append('<div class="col-md-4">'+url+'</div>')
    .append('<div class="col-md-2">'+delay+' ms</div>')
    .append('<div class="col-md-2">'+
      '<button type="button" class="btn btn-default">Stop job</button></div>')
  $(".jobs .job-"+job_id+" button").click(function(e) {
    jQuery.ajax("/rest/job/"+job_id, { success: function(e) {
      $(".jobs .job-"+job_id+" button").text("Start job")
    } })

  })
}

function add_job() {
   var url = $(".job-url").val()
   var delay = $(".job-delay").val()
   jQuery.ajax("/rest/job/"+url+"/"+delay, { 
     success: function(job_id) { display_job(job_id, url, delay) }
    })
}

$(function() {
  $(".jobs").append('<div class="row job-header">')
  $(".jobs .job-header")
    .append('<div class="col-md-2">Job ID</div>')
    .append('<div class="col-md-2">Type</div>')
    .append('<div class="col-md-4">Endpoint</div>')
    .append('<div class="col-md-2">Delay (ms)</div>')
    .append('<div class="col-md-2"></div>')
   load_jobs()

   $('.job-submit').click(add_job)
})

