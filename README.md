# Pdftk

This is a Ruby Wrapper for a pdftk command line tool.

Before using this gem, make sure you have 'pdftk' installed:

    sudo apt-get install pdftk

or

    brew install pdftk

## Installation

Add this line to your application's Gemfile:

    gem 'pdftk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pdftk

## Usage

require 'pdftk'

Pdftk.pdf_info(filepath)
Pdftk.pages_count(filepath)
