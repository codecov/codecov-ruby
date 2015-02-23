require 'uri'
require 'json'
require 'net/http'

class SimpleCov::Formatter::Codecov
  VERSION = "0.0.2"
  def format(result)
    # =================
    # Build JSON Report
    # =================
    report = {
      "meta" => {
        "version" => "codecov-python/v"+SimpleCov::Formatter::Codecov::VERSION,
      },
      "coverage" => {}
    }

    result.files.each do |sourceFile|
      next unless result.filenames.include? sourceFile.filename
      # https://github.com/colszowka/simplecov/blob/fee9dcf1f990a57503b0d518d9844a7209db4734/lib/simplecov/source_file.rb
      lines = [nil] * (sourceFile.lines_of_code + 1)
      sourceFile.coverage.each_with_index {|h,x| lines[x+1]=h if h }
      report["coverage"][sourceFile.filename] = lines
    end

    json = report.to_json

    # ==============
    # CI Environment
    # ==============
    # add params
    params = {"token" => ENV['CODECOV_TOKEN']}

    # Travis CI
    # ---------
    if ENV['CI'] == "true" and ENV['TRAVIS'] == "true"
        # http://docs.travis-ci.com/user/ci-environment/#Environment-variables
        params[:branch] = ENV['TRAVIS_BRANCH']
        params[:pull_request] = ENV['TRAVIS_PULL_REQUEST']!='false' ? ENV['TRAVIS_PULL_REQUEST'] : ''
        params[:travis_job_id] = ENV['TRAVIS_JOB_ID']
        params[:commit] = ENV['TRAVIS_COMMIT']

    # Codeship
    # --------
    elsif ENV['CI'] == "true" and ENV['CI_NAME'] == 'codeship'
        # https://www.codeship.io/documentation/continuous-integration/set-environment-variables/
        params[:branch] = ENV['CI_BRANCH']
        params[:commit] = ENV['CI_COMMIT_ID']

    # Circle CI
    # ---------
    elsif ENV['CI'] == "true" and ENV['CIRCLECI'] == 'true'
        # https://circleci.com/docs/environment-variables
        params[:branch] = ENV['CIRCLE_BRANCH']
        params[:commit] = ENV['CIRCLE_SHA1']

    # Semaphore
    # ---------
    elsif ENV['CI'] == "true" and ENV['SEMAPHORE'] == "true"
        # https://semaphoreapp.com/docs/available-environment-variables.html
        params[:branch] = ENV['BRANCH_NAME']
        params[:commit] = ENV['REVISION']

    # drone.io
    # --------
    elsif ENV['CI'] == "true" and ENV['DRONE'] == "true"
        # https://semaphoreapp.com/docs/available-environment-variables.html
        params[:branch] = ENV['DRONE_BRANCH']
        params[:commit] = ENV['DRONE_COMMIT']

    # git
    # ---
    else
        # find branch, commit, repo from git command
        branch = `git rev-parse --abbrev-ref HEAD`.strip
        params[:branch] = branch != 'HEAD' ? branch : 'master'
        params[:commit] = `git rev-parse HEAD`.strip

    end

    # =================
    # Build URL Request
    # =================
    url = ENV['CODECOV_URL'] || "https://codecov.io"
    uri = URI.parse(url+"/upload/v1")

    uri.query = URI.encode_www_form(params)
    
    # get https
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = url.match(/^https/) != nil

    req = Net::HTTP::Post.new(uri.path + "?" + uri.query, {'Content-Type' => 'application/json'})
    req.body = json

    # make resquest
    response = https.request(req)

    # print to output
    puts response.body
    
    # join the response to report
    report['result'] = JSON.parse(response.body)

    # return json data
    report
  end
end
