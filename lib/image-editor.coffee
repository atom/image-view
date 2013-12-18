path = require 'path'
{_, Model, fs} = require 'atom'

# Public: Manages the states between {Editor}s, images, and the project as a whole.
#
# Essentially, the graphical version of a {EditSession}.
module.exports =
class ImageEditor extends Model
  atom.registerRepresentationClass(this)

  @properties
    path: null

  @behavior 'relativePath', ->
    @$path.map (path) -> atom.project.relativize(path)

  @activate: ->
    # Files with these extensions will be opened as images
    imageExtensions = ['.gif', '.jpeg', '.jpg', '.png']
    atom.project.registerOpener (filePath) ->
      if _.include(imageExtensions, path.extname(filePath))
        new ImageEditor(path: filePath)

  getViewClass: ->
    require './image-editor-view'

  # Deprecated: This is only present for backward compatibility with current pane
  # items implementation
  serialize: -> this

  ### Public ###

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

  # Compares two `ImageEditor`s to determine equality.
  #
  # Equality is based on the condition that the two URIs are the same.
  #
  # Returns a {Boolean}.
  isEqual: (other) ->
    other instanceof ImageEditor and @getUri() is other.getUri()
