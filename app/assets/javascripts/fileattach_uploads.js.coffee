jQuery ->
  $(document).on "upload:start", "form", (e) ->
    $(this).find("input[type=submit]").attr "disabled", true
    $("#progress_load").text("Pobieranie...")

  $(document).on "upload:progress", "form", (e) ->
    detail          = e.originalEvent.detail
    percentComplete = Math.round(detail.loaded / detail.total * 100)
    $("#progress_load").css("width", percentComplete+'%').attr('aria-valuenow', percentComplete) 
    $("#progress_load").text("Pobrano #{percentComplete}%")

  $(document).on "upload:success", "form", (e) ->
    $(this).find("input[type=submit]").removeAttr "disabled"  unless $(this).find("input.uploading").length

