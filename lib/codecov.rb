require 'uri'
require 'json'
require 'net/http'

class SimpleCov::Formatter::Codecov
  VERSION = "0.0.3"
  def format(result)
    # =================
    # Build JSON Report
    # =================
    report = {
      "meta" => {
        "version" => "codecov-python/v"+SimpleCov::Formatter::Codecov::VERSION,
      },
      "coverage" => result_to_codecov(result),
    }

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
        params[:service] = "travis-org"
        params[:branch] = ENV['TRAVIS_BRANCH']
        params[:pull_request] = ENV['TRAVIS_PULL_REQUEST']!='false' ? ENV['TRAVIS_PULL_REQUEST'] : ''
        params[:travis_job_id] = ENV['TRAVIS_JOB_ID']
        params[:owner] = ENV['TRAVIS_REPO_SLUG'].split('/')[0]
        params[:repo] = ENV['TRAVIS_REPO_SLUG'].split('/')[1]
        params[:build] = ENV['TRAVIS_JOB_NUMBER']
        params[:commit] = ENV['TRAVIS_COMMIT']

    # Codeship
    # --------
    elsif ENV['CI'] == "true" and ENV['CI_NAME'] == 'codeship'
        # https://www.codeship.io/documentation/continuous-integration/set-environment-variables/
        params[:service] = 'codeship'
        params[:branch] = ENV['CI_BRANCH']
        params[:commit] = ENV['CI_COMMIT_ID']
        params[:build] = ENV['CI_BUILD_NUMBER']
        params[:build_url] = ENV['CI_BUILD_URL']

    # Circle CI
    # ---------
    elsif ENV['CI'] == "true" and ENV['CIRCLECI'] == 'true'
        # https://circleci.com/docs/environment-variables
        params[:service] = 'circleci'
        params[:build] = ENV['CIRCLE_BUILD_NUM']
        params[:owner] = ENV['CIRCLE_PROJECT_USERNAME']
        params[:repo] = ENV['CIRCLE_PROJECT_REPONAME']
        params[:branch] = ENV['CIRCLE_BRANCH']
        params[:commit] = ENV['CIRCLE_SHA1']

    # Semaphore
    # ---------
    elsif ENV['CI'] == "true" and ENV['SEMAPHORE'] == "true"
        # https://semaphoreapp.com/docs/available-environment-variables.html
        params[:service] = 'semaphore'
        params[:branch] = ENV['BRANCH_NAME']
        params[:commit] = ENV['REVISION']
        params[:build] = ENV['SEMAPHORE_BUILD_NUMBER']
        params[:owner] = ENV['SEMAPHORE_REPO_SLUG'].split('/')[0]
        params[:repo] = ENV['SEMAPHORE_REPO_SLUG'].split('/')[1]

    # drone.io
    # --------
    elsif ENV['CI'] == "true" and ENV['DRONE'] == "true"
        # https://semaphoreapp.com/docs/available-environment-variables.html
        params[:service] = 'drone.io'
        params[:branch] = ENV['DRONE_BRANCH']
        params[:commit] = ENV['DRONE_COMMIT']
        params[:build] = ENV['DRONE_BUILD_NUMBER']
        params[:build_url] = ENV['DRONE_BUILD_URL']

    # Appveyor
    # --------
    elsif ENV['CI'] == "True" and ENV['APPVEYOR'] == 'True'
        # http://www.appveyor.com/docs/environment-variables
        params[:service] = "appveyor"
        params[:branch] = ENV['APPVEYOR_REPO_BRANCH']
        params[:build] = ENV['APPVEYOR_BUILD_NUMBER']
        params[:owner] = ENV['APPVEYOR_REPO_NAME'].split('/')[0]
        params[:repo] = ENV['APPVEYOR_REPO_NAME'].split('/')[1]
        params[:commit] = ENV['APPVEYOR_REPO_COMMIT']

    # Wercker
    # -------
    elsif ENV['CI'] == "true" and ENV['WERCKER_GIT_BRANCH'] != nil
        # http://devcenter.wercker.com/articles/steps/variables.html
        params[:service] = "wercker"
        params[:branch] = ENV['WERCKER_GIT_BRANCH']
        params[:build] = ENV['WERCKER_MAIN_PIPELINE_STARTED']
        params[:owner] = ENV['WERCKER_GIT_OWNER']
        params[:repo] = ENV['WERCKER_GIT_REPOSITORY']
        params[:commit] = ENV['WERCKER_GIT_COMMIT']

    # Jenkins
    # --------
    elsif ENV['JENKINS_URL'] != nil
        # https://wiki.jenkins-ci.org/display/JENKINS/Building+a+software+project
        params[:service] = 'jenkins'
        params[:branch] = ENV['GIT_BRANCH']
        params[:commit] = ENV['GIT_COMMIT']
        params[:build] = ENV['BUILD_NUMBER']
        params[:root] = ENV['WORKSPACE']
        params[:build_url] = ENV['BUILD_URL']

    # Shippable
    # ---------
    elsif ENV['SHIPPABLE'] == "true"
        # http://docs.shippable.com/en/latest/config.html#common-environment-variables
        params[:service] = 'shippable'
        params[:branch] = ENV['BRANCH']
        params[:build] = ENV['BUILD_NUMBER']
        params[:build_url] = ENV['BUILD_URL']
        params[:pull_request] = ENV['PULL_REQUEST']!='false' ? ENV['PULL_REQUEST'] : ''
        params[:owner] = ENV['REPO_NAME'].split('/')[0]
        params[:repo] = ENV['REPO_NAME'].split('/')[1]
        params[:commit] = ENV['COMMIT']

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

  private

  # Format SimpleCov coverage data for the Codecov.io API.
  #
  # @param result [SimpleCov::Result] The coverage data to process.
  # @return [Hash<String, Array<nil, Integer>>]
  def result_to_codecov(result)
    result.files.inject({}) do |memo, file|
      if result.filenames.include?(file.filename)
        memo[file.filename] = file_to_codecov(file)
      end
      memo
    end
  end

  # Format coverage data for a single file for the Codecov.io API.
  #
  # @param file [SimpleCov::SourceFile] The file to process.
  # @return [Array<nil, Integer>]
  def file_to_codecov(file)
    # Initial nil is required to offset line numbers.
    [nil] + file.lines.map do |line|
      if line.skipped?
        nil
      else
        line.coverage
      end
    end
  end
end
