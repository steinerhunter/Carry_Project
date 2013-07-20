$('#<%= dom_id(@comment) %>')
  .fadeOut ->
    $(this).remove()
