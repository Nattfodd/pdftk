require_relative 'errors'
require_relative 'version'

require 'posix'
require 'byebug'

# Ruby Wrapper for PDFTK command line tool
module Pdftk
  extend Posix

  DEFAULT_FOLDER = "/tmp/pdftk-tempfiles/#{Process.pid}_#{SecureRandom.uuid}"

  def self.pages_count(pdf_path)
    pdf_info(pdf_path)[/NumberOfPages:\s*(\d+)/, 1].to_i
  end

  def self.for_each_pdf_part(pdf_path, max_pages_per_pdf)
    pages = pages_count(pdf_path)
    return yield(pdf_path) if max_pages_per_pdf.nil? ||
                              pages <= max_pages_per_pdf

    (pages / max_pages_per_pdf + 1).times do |pdf_number|
      from_page = pdf_number * max_pages_per_pdf + 1
      break if from_page > pages

      to_page = (pdf_number + 1) * max_pages_per_pdf
      to_page = pages if to_page > pages

      split_pdf(pdf_path, from_page, to_page) do |cutted_pdf|
        yield cutted_pdf
      end
    end
  end

  def self.password_protected?(error_text)
    error_text[/has set an owner password/]
  end

  def self.protected_pdf?(path)
    password_protected?(pdf_info(path))
  end

  def self.pdf_info(path)
    raise(FileNotFound, path) unless File.exists?(path)

    Posix.exec('pdftk', path, 'dump_data') do |result|
      return result.err + result.out
    end
  end

  def self.recreate_pdf(path)
    FileUtils::mkdir_p DEFAULT_FOLDER
    filename = File.basename(path)
    new_path = DEFAULT_FOLDER + "/#{filename}"
    Posix.exec('pdftk', path, 'output', new_path) do |result|
      error_text = result.err
      raise(error_text) unless password_protected?(error_text)
    end

    new_path
  end

  private
  ############################################################################

  def self.split_pdf(pdf_path, from_page, to_page)
    FileUtils::mkdir_p DEFAULT_FOLDER

    range = "#{from_page}-#{to_page}"
    filename = File.basename pdf_path, '.*'
    result_path = "#{DEFAULT_FOLDER}/#{filename}_#{range}.pdf"
    command = "pdftk #{pdf_path} cat #{range} output #{result_path}"

    args = [ 'pdftk', pdf_path, 'cat', range, 'output', result_path ]
    Posix.exec(*args) do |result|
      error_text = result.err
      raise(error_text) unless error_text.empty?
    end

    yield result_path

    FileUtils.rm_rf DEFAULT_FOLDER
  end
end
