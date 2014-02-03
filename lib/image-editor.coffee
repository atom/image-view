path = require 'path'
{Model} = require 'theorist'
Serializable = require 'serializable'
{_, fs} = require 'atom'

# Editor model for an image file
module.exports =
class ImageEditor extends Model
  Serializable.includeInto(this)
  atom.deserializers.add(this)

  @properties
    path: null

  @behavior 'relativePath', ->
    @$path.map (path) -> atom.project.relativize(path)

  @activate: ->
    # Files with these extensions will be opened as images
    imageExtensions = ['.gif', '.ico', '.jpeg', '.jpg', '.png']
    atom.project.registerOpener (filePath) ->
      if _.include(imageExtensions, path.extname(filePath))
        new ImageEditor(path: filePath)

  serializeParams: ->
    {@path}

  deserializeParams: (params) ->
    if fs.isFileSync(params.path)
      params
    else
      console.warn "Could not deserialize image editor for path '#{params.path}' because that file no longer exists"

  getViewClass: ->
    require './image-editor-view'

  # Retrieves the filename of the open file.
  #
  # This is `'untitled'` if the file is new and not saved to the disk.
  #
  # Returns a {String}.
  getTitle: ->
    if @path?
      path.basename(@path)
    else
      'untitled'

  # Retrieves the URI of the current image.
  #
  # Returns a {String}.
  getUri: -> @relativePath

  # Compares two {ImageEditor}s to determine equality.
  #
  # Equality is based on the condition that the two URIs are the same.
  #
  # Returns a {Boolean}.
  isEqual: (other) ->
    other instanceof ImageEditor and @getUri() is other.getUri()
