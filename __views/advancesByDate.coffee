(doc) ->
  emit(doc.changeTimestamps[0]) if doc.type is "Advance"
