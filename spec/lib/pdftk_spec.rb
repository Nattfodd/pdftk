require 'spec_helper'

describe Pdftk do
  let(:pdf_path) { 'spec/pdfs/test.pdf' }
  let(:protected_pdf_path) { 'spec/pdfs/password_protected.pdf' }
  let(:unprotected_pdf_path) { 'spec/pdfs/unprotected.pdf' }

  describe '#pages_count' do
    it 'returns amount of pages in PDF' do
      expect(Pdftk.pages_count(pdf_path)).to eq 12
    end

    it 'raises error when there is no such file' do
      expect { Pdftk.pages_count('some_file') }.
        to raise_error(Pdftk::FileNotFound)
    end
  end

  describe '#for_each_pdf_part' do
    it 'splits pdf onto parts of given amount of pages' do
      amount_of_splits = 0
      Pdftk.for_each_pdf_part(pdf_path, 2) do |shorter_pdf_path|
        amount_of_splits += 1
        expect(File.exists?(shorter_pdf_path)).to be_truthy
        expect(Pdftk.pages_count(shorter_pdf_path)).to eq 2
      end

      expect(amount_of_splits).to eq 6
    end
  end

  describe '#protected_pdf?' do
    it 'returns true for password protected file' do
      expect(Pdftk.protected_pdf?(protected_pdf_path)).
        to be_truthy
    end

    it 'returns false for non-protected file' do
      expect(Pdftk.protected_pdf?(unprotected_pdf_path)).
        to be_falsey
    end
  end

  describe '#recreate_pdf' do
    it 'recreates pdf from a provided one' do
      new_pdf_path = Pdftk.recreate_pdf(protected_pdf_path)
      expect(FileUtils.compare_file(protected_pdf_path, new_pdf_path)).
        to be_falsey
      FileUtils.rm new_pdf_path
    end
  end
end
