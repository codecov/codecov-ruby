require 'uri'
require 'json'
require 'net/http'

class SimpleCov::Formatter::Codecov
  VERSION = "0.1.3"
  def format(result)
    net_blockers(:off)

    # =================
    # Build JSON Report
    # =================
    report = {
      "meta" => {
        "version" => "codecov-ruby/v"+SimpleCov::Formatter::Codecov::VERSION,
      }
    }
    report.update(result_to_codecov(result))

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
        params[:service] = "travis"
        params[:branch] = ENV['TRAVIS_BRANCH']
        params[:pull_request] = ENV['TRAVIS_PULL_REQUEST']
        params[:job] = ENV['TRAVIS_JOB_ID']
        params[:slug] = ENV['TRAVIS_REPO_SLUG']
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
        params[:build] = ENV['CIRCLE_BUILD_NUM'] + '.' + ENV['CIRCLE_NODE_INDEX']
        params[:slug] = ENV['CIRCLE_PROJECT_USERNAME'] + '/' + ENV['CIRCLE_PROJECT_REPONAME']
        params[:pr] = ENV['CIRCLE_PR_NUMBER']
        params[:branch] = ENV['CIRCLE_BRANCH']
        params[:commit] = ENV['CIRCLE_SHA1']

    # Buildkite
    # ---------
    elsif ENV['CI'] == "true" and ENV['BUILDKITE'] == "true"
      # https://buildkite.com/docs/guides/environment-variables
      params[:service] = "buildkite"
      params[:branch] = ENV['BUILDKITE_BRANCH']
      params[:build] = ENV['BUILDKITE_BUILD_NUMBER']
      params[:build_url] = ENV['BUILDKITE_BUILD_URL']
      params[:slug] = ENV['BUILDKITE_PROJECT_SLUG']
      params[:commit] = ENV['BUILDKITE_COMMIT']

    # Semaphore
    # ---------
    elsif ENV['CI'] == "true" and ENV['SEMAPHORE'] == "true"
        # https://semaphoreapp.com/docs/available-environment-variables.html
        params[:service] = 'semaphore'
        params[:branch] = ENV['BRANCH_NAME']
        params[:commit] = ENV['REVISION']
        params[:build] = ENV['SEMAPHORE_BUILD_NUMBER'] + '.' + ENV['SEMAPHORE_CURRENT_THREAD']
        params[:slug] = ENV['SEMAPHORE_REPO_SLUG']

    # Snap CI
    # -------
    elsif ENV['CI'] == "true" and ENV['SNAP_CI'] == "true"
        # https://docs.snap-ci.com/environment-variables/
        params[:service] = 'snap'
        params[:branch] = ENV['SNAP_BRANCH'] || ENV['SNAP_UPSTREAM_BRANCH']
        params[:commit] = ENV['SNAP_COMMIT'] || ENV['SNAP_UPSTREAM_COMMIT']
        params[:build] = ENV['SNAP_PIPELINE_COUNTER']
        params[:pr] = ENV['SNAP_PULL_REQUEST_NUMBER']

    # drone.io
    # --------
    elsif ENV['CI'] == "true" and ENV['DRONE'] == "true"
        # https://semaphoreapp.com/docs/available-environment-variables.html
        params[:service] = 'drone.io'
        params[:branch] = ENV['DRONE_BRANCH']
        params[:commit] = `git rev-parse HEAD`.strip
        params[:build] = ENV['DRONE_BUILD_NUMBER']
        params[:build_url] = ENV['DRONE_BUILD_URL']

    # Appveyor
    # --------
    elsif ENV['CI'] == "True" and ENV['APPVEYOR'] == 'True'
        # http://www.appveyor.com/docs/environment-variables
        params[:service] = "appveyor"
        params[:branch] = ENV['APPVEYOR_REPO_BRANCH']
        params[:build] = ENV['APPVEYOR_JOB_ID']
        params[:pr] = ENV['APPVEYOR_PULL_REQUEST_NUMBER']
        params[:job] = ENV['APPVEYOR_ACCOUNT_NAME'] + '/' + ENV['APPVEYOR_PROJECT_SLUG'] + '/' + ENV['APPVEYOR_BUILD_VERSION']
        params[:slug] = ENV['APPVEYOR_REPO_NAME']
        params[:commit] = ENV['APPVEYOR_REPO_COMMIT']

    # Wercker
    # -------
    elsif ENV['CI'] == "true" and ENV['WERCKER_GIT_BRANCH'] != nil
        # http://devcenter.wercker.com/articles/steps/variables.html
        params[:service] = "wercker"
        params[:branch] = ENV['WERCKER_GIT_BRANCH']
        params[:build] = ENV['WERCKER_MAIN_PIPELINE_STARTED']
        params[:slug] = ENV['WERCKER_GIT_OWNER'] + '/' + ENV['WERCKER_GIT_REPOSITORY']
        params[:commit] = ENV['WERCKER_GIT_COMMIT']

    # Jenkins
    # --------
    elsif ENV['JENKINS_URL'] != nil
        # https://wiki.jenkins-ci.org/display/JENKINS/Building+a+software+project
        # https://wiki.jenkins-ci.org/display/JENKINS/GitHub+pull+request+builder+plugin#GitHubpullrequestbuilderplugin-EnvironmentVariables
        params[:service] = 'jenkins'
        params[:branch] = ENV['ghprbSourceBranch'] || ENV['GIT_BRANCH']
        params[:commit] = ENV['ghprbActualCommit'] || ENV['GIT_COMMIT']
        params[:pr] = ENV['ghprbPullId']
        params[:build] = ENV['BUILD_NUMBER']
        params[:root] = ENV['WORKSPACE']
        params[:build_url] = ENV['BUILD_URL']

    # Shippable
    # ---------
    elsif ENV['CI'] == 'true' and ENV['SHIPPABLE'] == "true"
        # http://docs.shippable.com/en/latest/config.html#common-environment-variables
        params[:service] = 'shippable'
        params[:branch] = ENV['BRANCH']
        params[:build] = ENV['BUILD_NUMBER']
        params[:build_url] = ENV['BUILD_URL']
        params[:pull_request] = ENV['PULL_REQUEST']
        params[:slug] = ENV['REPO_NAME']
        params[:commit] = ENV['COMMIT']

    # GitLab CI
    # ---------
    elsif ENV['CI_SERVER_NAME'] == 'GitLab CI'
        # http://doc.gitlab.com/ci/examples/README.html#environmental-variables
        # https://gitlab.com/gitlab-org/gitlab-ci-runner/blob/master/lib/build.rb#L96
        params[:service] = 'gitlab'
        params[:branch] = ENV['CI_BUILD_REF_NAME']
        params[:build] = ENV['CI_BUILD_ID']
        params[:slug] = ENV['CI_BUILD_REPO'].split('/', 4)[-1].sub('.git', '')
        params[:commit] = ENV['CI_BUILD_REF']
    end

    if params[:branch] == nil
        # find branch, commit, repo from git command
        branch = `git rev-parse --abbrev-ref HEAD`.strip
        params[:branch] = branch != 'HEAD' ? branch : 'master'
    end

    if params[:commit] == nil
        params[:commit] = `git rev-parse HEAD`.strip
    end

    slug = ENV['CODECOV_SLUG']
    if slug != nil
        params[:slug] = slug
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

    req = Net::HTTP::Post.new(uri.path + "?" + uri.query,
                              {
                                'Content-Type' => 'application/json',
                                'Accept' => 'application/json'
                              })
    req.body = json

    # make resquest
    response = https.request(req)

    # print to output
    puts response.body

    # join the response to report
    report['result'] = JSON.parse(response.body)
    report['params'] = params
    report['query'] = uri.query

    net_blockers(:on)

    # return json data
    report
  end

  private

  # Format SimpleCov coverage data for the Codecov.io API.
  #
  # @param result [SimpleCov::Result] The coverage data to process.
  # @return [Hash]
  def result_to_codecov(result)
    {
      'coverage' => result_to_codecov_coverage(result),
      'messages' => result_to_codecov_messages(result),
    }
  end

  # Format SimpleCov coverage data for the Codecov.io coverage API.
  #
  # @param result [SimpleCov::Result] The coverage data to process.
  # @return [Hash<String, Array>]
  def result_to_codecov_coverage(result)
    result.files.inject({}) do |memo, file|
      memo[shortened_filename(file)] = file_to_codecov(file)
      memo
    end
  end

  # Format SimpleCov coverage data for the Codecov.io messages API.
  #
  # @param result [SimpleCov::Result] The coverage data to process.
  # @return [Hash<String, Hash>]
  def result_to_codecov_messages(result)
    result.files.inject({}) do |memo, file|
      memo[shortened_filename(file)] = file.lines.inject({}) do |lines_memo, line|
        lines_memo[line.line_number.to_s] = 'skipped' if line.skipped?
        lines_memo
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

  # Get a filename relative to the project root. Based on
  # https://github.com/colszowka/simplecov-html, copyright Christoph Olszowka.
  #
  # @param file [SimeplCov::SourceFile] The file to use.
  # @return [String]
  def shortened_filename(file)
    file.filename.gsub(/^#{SimpleCov.root}/, '.').gsub(/^\.\//, '')
  end


  # Toggle VCR and WebMock on or off
  #
  # @param switch Toggle switch for Net Blockers.
  # @return [Boolean]
  def net_blockers(switch)
    throw 'Only :on or :off' unless [:on, :off].include? switch

    if defined?(VCR)
      @vcr_enabled ||= VCR.turned_on?
      VCR.send "turn_#{switch}!".to_sym if @vcr_enabled
    end

    if defined?(WebMock)
      # WebMock on by default
      # VCR depends on WebMock 1.8.11; no method to check whether enabled.
      action = case switch
      when :on
        'disable'
      when :off
        'allow'
      end
      WebMock.send "#{action}_net_connect!".to_sym
    end

    return true

  end

end
