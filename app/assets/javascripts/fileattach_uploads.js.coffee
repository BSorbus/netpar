jQuery ->
  $(document).on "upload:start", "form", (e) ->
    $(this).find("input[type=submit]").attr "disabled", true
    $("#progress_load_text").text("Pobieranie...")

  $(document).on "upload:progress", "form", (e) ->
    detail          = e.originalEvent.detail
    percentComplete = Math.round(detail.progress.loaded / detail.progress.total * 100)
    $("#progress_load_text").css("width", percentComplete+'%').attr('aria-valuenow', percentComplete) 
    $("#progress_load_text").text("Pobrano #{percentComplete}%")

  $(document).on "upload:success", "form", (e) ->
    $(this).find("input[type=submit]").removeAttr "disabled"  unless $(this).find("input.uploading").length

