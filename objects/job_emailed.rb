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
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'mail'

#
# Job that emails if exception occurs.
#
class JobEmailed
  def initialize(name, repo, config, job)
    @name = name
    @repo = repo
    @job = job
    return unless config['smtp']
    Mail.defaults do
      delivery_method(
        :smtp,
        address: config['smtp']['host'],
        port: config['smtp']['port'],
        user_name: config['smtp']['user'],
        password: config['smtp']['password'],
        domain: '0pdd.com',
        enable_starttls_auto: true
      )
    end
  end

  def proceed
    @job.proceed
  rescue Exception => e
    yaml = @repo.config
    if yaml['errors']
      trace = e.message + "\n\n" + e.backtrace.join("\n")
      name = @name
      yaml['errors'].each do |email|
        mail = Mail.new do
          from '0pdd <no-reply@0pdd.com>'
          to email
          subject "#{name}: puzzles discovery problem"
          text_part do
            content_type 'text/plain; charset=UTF-8'
            body "Hey,\n\n\
There is a problem in #{name}:\n\n\
#{trace}\n\n\
If you think it's our bug, please forward this email to yegor@0pdd.com.
Sorry,\n\
0pdd"
          end
          html_part do
            content_type 'text/html; charset=UTF-8'
            body "<html><body><p>Hey,</p>
              <p>There is a problem in #{name}:</p>
              <pre>#{trace}</pre>
              <p>If you think it's our bug, please forward this email
              to <a href='mailto:yegor@0pdd.com'>yegor@0pdd.com</a>. Thanks.</p>
              <p>Sorry,<br/><a href='http://www.0pdd.com'>0pdd</a></p>"
          end
        end
        mail.deliver!
        puts "email sent to #{email}"
      end
    end
    raise e
  end
end
