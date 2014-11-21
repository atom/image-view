path = require 'path'
fs = require 'fs-plus'
{File} = require 'pathwatcher'
{CompositeDisposable} = require 'atom'

# Editor model for an image file
module.exports =
class ImageEditor
  atom.deserializers.add(this)

  @deserialize: ({filePath}) ->
    if fs.isFileSync(filePath)
      new ImageEditor(filePath)
    else
      console.warn "Could not deserialize image editor for path '#{filePath}' because that file no longer exists"

  constructor: (filePath) ->
    @file = new File(filePath)

  serialize: ->
    {filePath: @getPath(), deserializer: @constructor.name}

  getViewClass: ->
    require './image-editor-view'

  # Register a callback for when the image file changes
  onDidChange: (callback) ->
    @file.onDidChange(callback)

  # Register a callback for whne the image's title changes
  onDidChangeTitle: (callback) ->
    @file.onDidRename(callback)

  # Retrieves the filename of the open file.
  #
  # This is `'untitled'` if the file is new and not saved to the disk.
  #
  # Returns a {String}.
  getTitle: ->
    if filePath = @getPath()
      path.basename(filePath)
    else
      'untitled'

  # Retrieves the URI of the image.
  #
  # Returns a {String}.
  getUri: -> @getPath()

  # Retrieves the absolute path to the image.
  #
  # Returns a {String} path.
  getPath: -> @file.getPath()

  # Compares two {ImageEditor}s to determine equality.
  #
  # Equality is based on the condition that the two URIs are the same.
  #
  # Returns a {Boolean}.
  isEqual: (other) ->
    other instanceof ImageEditor and @getUri() is other.getUri()
