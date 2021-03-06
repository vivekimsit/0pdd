# encoding: utf-8
#
# Copyright (c) 2016 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'nokogiri'
require 'simplecov'
require 'tempfile'

ENV['RACK_ENV'] = 'test'

class FakeStorage
  def initialize(
    dir = Dir.mktmpdir,
    xml = '<puzzles date="2016-12-10T16:26:36Z" version="0.1"/>'
  )
    @file = File.join(dir, 'storage.xml')
    save(xml)
  end

  def load
    Nokogiri.XML(IO.read(@file))
  end

  def save(xml)
    IO.write(@file, xml.to_s)
  end
end

class FakeTickets
  attr_reader :submitted, :closed
  def initialize
    @submitted = []
    @closed = []
  end

  def submit(puzzle)
    @submitted << puzzle.xpath('id').text
    { number: '123', href: 'http://0pdd.com' }
  end

  def close(puzzle)
    @closed << puzzle.xpath('id').text
  end
end

class FakeRepo
  def lock
    Tempfile.new('0pdd-lock')
  end

  def config
    {}
  end

  def xml
    Nokogiri::XML('<puzzles date="2016-12-10T16:26:36Z"/>')
  end

  def push
    # nothing here
  end
end
