# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $(".tag-button").change ->
    $label = $(this)
    if !$label.hasClass("active")
      $.ajax
        type:"POST"
        url: "/tags/update_push.json"
        data: 'update_tags=[{"photo_id":' + $label.attr("data-photo-id") + ',"member_id":' + $label.attr("data-member-id") + ', "mode":"add"}]'
    else
      $.ajax
        type:"POST"
        url: "/tags/update_push.json"
        data: 'update_tags=[{"photo_id":' + $label.attr("data-photo-id") + ',"member_id":' + $label.attr("data-member-id") + ', "mode":"del"}]'
  