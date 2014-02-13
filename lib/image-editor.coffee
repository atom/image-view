path = require 'path'
fs = require 'fs-plus'

# Editor model for an image file
module.exports =
class ImageEditor
  atom.deserializers.add(this)

  @deserialize: ({filePath}) ->
    if fs.isFileSync(filePath)
      new ImageEditor(filePath)
    else
      console.warn "Could not deserialize image editor for path '#{filePath}' because that file no longer exists"

  constructor: (@filePath) ->
    console.log @filePath

  serialize: ->
    {@filePath}

  getViewClass: ->
    require './image-editor-view'

  # Retrieves the filename of the open file.
  #
  # This is `'untitled'` if the file is new and not saved to the disk.
  #
  # Returns a {String}.
  getTitle: ->
    if @filePath?
      path.basename(@filePath)
    else
      'untitled'

  # Retrieves the URI of the current image.
  #
  # Returns a {String}.
  getUri: ->
    @filePath

  # Compares two {ImageEditor}s to determine equality.
  #
  # Equality is based on the condition that the two URIs are the same.
  #
  # Returns a {Boolean}.
  isEqual: (other) ->
    other instanceof ImageEditor and @getUri() is other.getUri()
