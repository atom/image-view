{Document} = require 'atom'
ImageEditor = require '../lib/image-editor'

describe "ImageEditor", ->
  it "destroys itself upon creation if no file exists at the given path", ->
    doc = Document.create()
    doc.set('imageEditor', new ImageEditor(path: "bogus"))
    expect(doc.has('imageEditor')).toBe false
