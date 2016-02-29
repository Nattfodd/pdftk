module Pdftk
  class PdftkError < StandardError
  end

  class FileNotFound < PdftkError
    def initialize(filename)
      super("File <#{filename}> could not be found.")
    end
  end
end
