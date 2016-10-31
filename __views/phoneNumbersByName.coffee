(doc) ->
  emit(doc.Name, doc["Phone Number"]) if doc.type is "Advance"
