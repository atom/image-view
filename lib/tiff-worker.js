importScripts('../node_modules/tiff.js/tiff.js')
// This implementation is copied from https://raw.githubusercontent.com/seikichi/tiff.js/master/tiff.js
// The reason it is copied, is because `Tiff.toCanvas` needs `document.createElement`
// However, web workers do not have access to the document.
// Therefore, do as much work here (decoding the image using tiff.js)
// and then pass on the imageBuffer to the main thread to compute the final image
// using a canvas.
onmessage = function(e) {
  const tiffImage = new Tiff({ buffer: e.data })
  const width = tiffImage.width()
  const height = tiffImage.height()
  const raster = Tiff.Module.ccall('_TIFFmalloc', 'number', ['number'], [width * height * 4])
  const result = Tiff.Module.ccall('TIFFReadRGBAImageOriented', 'number', [
      'number', 'number', 'number', 'number', 'number', 'number'], [
      tiffImage._tiffPtr, width, height, raster, 1, 0
  ])
  if (result === 0) {
      throw new Tiff.Exception('The function TIFFReadRGBAImageOriented returns NULL')
  }
  const imageBuffer = Tiff.Module.HEAPU8.subarray(raster, raster + width * height * 4)
  postMessage({
    width,
    height,
    imageBuffer
  })
}
