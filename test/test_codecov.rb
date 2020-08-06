# frozen_string_literal: true

require 'helper'

class TestCodecov < Minitest::Test
  REALENV = Marshal.load(Marshal.dump(ENV))

  def url
    ENV['CODECOV_URL'] || 'https://codecov.io'
  end

  def test_defined
    assert defined?(SimpleCov::Formatter::Codecov)
    assert defined?(SimpleCov::Formatter::Codecov::VERSION)
  end

  def stub_file(filename, coverage)
    lines = coverage.each_with_index.map do |cov, i|
      skipped = false
      if cov == :skipped
        skipped = true
        cov = 0
      end
      stub('SimpleCov::SourceFile::Line', skipped?: skipped, line_number: i + 1, coverage: cov)
    end
    stub('SimpleCov::SourceFile', filename: filename, lines: lines)
  end

  def upload(success=true)
    formatter = SimpleCov::Formatter::Codecov.new
    result = stub('SimpleCov::Result', files: [
                    stub_file('/path/lib/something.rb', [1, 0, 0, nil, 1, nil]),
                    stub_file('/path/lib/somefile.rb', [1, nil, 1, 1, 1, 0, 0, nil, 1, nil])
                  ])
    SimpleCov.stubs(:root).returns('/path')
    success_stubs if success
    data = formatter.format(result, false)
    puts data
    puts data['params']
    if success
      assert_successful_upload(data)
    end
    WebMock.reset!
    data
  end

  def success_stubs
    stub_request(:post, %r{https:\/\/codecov.io\/upload})
      .to_return(
        status: 200,
        body: "https://codecov.io/gh/fake\n" \
              'https://storage.googleapis.com/codecov/fake'
      )
    stub_request(:put, %r{https:\/\/storage.googleapis.com\/})
      .to_return(
        status: 200,
        body: ''
      )
  end

  def assert_successful_upload(data)
    assert_equal(data['result']['uploaded'], true)
    assert_equal(data['result']['message'], 'Coverage reports upload successfully')
    assert_equal(data['meta']['version'], 'codecov-ruby/v' + SimpleCov::Formatter::Codecov::VERSION)
    assert_equal(data['coverage'].to_json, {
      'lib/something.rb' => [nil, 1, 0, 0, nil, 1, nil],
      'lib/somefile.rb' => [nil, 1, nil, 1, 1, 1, 0, 0, nil, 1, nil]
    }.to_json)
  end

  def setup
    ENV['CI'] = nil
    ENV['TRAVIS'] = nil
  end

  def teardown
    # needed for sending this projects coverage
    REALENV.each_pair { |k, v| ENV[k] = v }
  end

  def test_git
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'
    result = upload
    assert_equal('f881216b-b5c0-4eb1-8f21-b51887d1d506', result['params']['token'])
    branch = `git rev-parse --abbrev-ref HEAD`.strip
    assert_equal(branch != 'HEAD' ? branch : 'master', result['params'][:branch])
    assert_equal(`git rev-parse HEAD`.strip, result['params'][:commit])
  end

  def test_travis
    ENV['CI'] = 'true'
    ENV['TRAVIS'] = 'true'
    ENV['TRAVIS_BRANCH'] = 'master'
    ENV['TRAVIS_COMMIT'] = 'c739768fcac68144a3a6d82305b9c4106934d31a'
    ENV['TRAVIS_JOB_ID'] = '33116958'
    ENV['TRAVIS_PULL_REQUEST'] = 'false'
    ENV['TRAVIS_JOB_NUMBER'] = '1'
    ENV['TRAVIS_REPO_SLUG'] = 'codecov/ci-repo'
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'
    result = upload
    assert_equal('travis', result['params'][:service])
    assert_equal('c739768fcac68144a3a6d82305b9c4106934d31a', result['params'][:commit])
    assert_equal('codecov/ci-repo', result['params'][:slug])
    assert_equal('1', result['params'][:build])
    assert_equal('33116958', result['params'][:job])
    assert_equal('false', result['params'][:pull_request])
    assert_equal('f881216b-b5c0-4eb1-8f21-b51887d1d506', result['params']['token'])
  end

  def test_codeship
    ENV['CI'] = 'true'
    ENV['CI_NAME'] = 'codeship'
    ENV['CI_BRANCH'] = 'master'
    ENV['CI_BUILD_NUMBER'] = '1'
    ENV['CI_COMMIT_ID'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'
    result = upload
    assert_equal('codeship', result['params'][:service])
    assert_equal('743b04806ea677403aa2ff26c6bdeb85005de658', result['params'][:commit])
    assert_equal('1', result['params'][:build])
    assert_equal('master', result['params'][:branch])
    assert_equal('f881216b-b5c0-4eb1-8f21-b51887d1d506', result['params']['token'])
  end

  def test_buildkite
    ENV['CI'] = 'true'
    ENV['BUILDKITE'] = 'true'
    ENV['BUILDKITE_BRANCH'] = 'master'
    ENV['BUILDKITE_BUILD_NUMBER'] = '1'
    ENV['BUILDKITE_JOB_ID'] = '2'
    ENV['BUILDKITE_BUILD_URL'] = 'http://demo'
    ENV['BUILDKITE_PROJECT_SLUG'] = 'owner/repo'
    ENV['BUILDKITE_COMMIT'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'
    result = upload
    assert_equal('buildkite', result['params'][:service])
    assert_equal('743b04806ea677403aa2ff26c6bdeb85005de658', result['params'][:commit])
    assert_equal('1', result['params'][:build])
    assert_equal('2', result['params'][:job])
    assert_equal('master', result['params'][:branch])
    assert_equal('owner/repo', result['params'][:slug])
    assert_equal('f881216b-b5c0-4eb1-8f21-b51887d1d506', result['params']['token'])
  end

  def test_jenkins
    ENV['JENKINS_URL'] = 'true'
    ENV['ghprbSourceBranch'] = 'master'
    ENV['BUILD_NUMBER'] = '1'
    ENV['ghprbActualCommit'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'
    ENV['BUILD_URL'] = 'https://jenkins'
    ENV['ghprbPullId'] = '1'
    result = upload
    assert_equal('jenkins', result['params'][:service])
    assert_equal('743b04806ea677403aa2ff26c6bdeb85005de658', result['params'][:commit])
    assert_equal('1', result['params'][:build])
    assert_equal('1', result['params'][:pr])
    assert_equal('master', result['params'][:branch])
    assert_equal('https://jenkins', result['params'][:build_url])
    assert_equal('f881216b-b5c0-4eb1-8f21-b51887d1d506', result['params']['token'])
  end

  def test_jenkins_2
    ENV['JENKINS_URL'] = 'true'
    ENV['GIT_BRANCH'] = 'master'
    ENV['BUILD_NUMBER'] = '1'
    ENV['GIT_COMMIT'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'
    ENV['BUILD_URL'] = 'https://jenkins'
    result = upload
    assert_equal('jenkins', result['params'][:service])
    assert_equal('743b04806ea677403aa2ff26c6bdeb85005de658', result['params'][:commit])
    assert_equal('1', result['params'][:build])
    assert_equal('master', result['params'][:branch])
    assert_equal('https://jenkins', result['params'][:build_url])
    assert_equal('f881216b-b5c0-4eb1-8f21-b51887d1d506', result['params']['token'])
  end

  def test_shippable
    ENV['CI'] = 'true'
    ENV['SHIPPABLE'] = 'true'
    ENV['BRANCH'] = 'master'
    ENV['BUILD_NUMBER'] = '1'
    ENV['BUILD_URL'] = 'http://shippable.com/...'
    ENV['PULL_REQUEST'] = 'false'
    ENV['REPO_NAME'] = 'owner/repo'
    ENV['COMMIT'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'
    result = upload
    assert_equal('shippable', result['params'][:service])
    assert_equal('743b04806ea677403aa2ff26c6bdeb85005de658', result['params'][:commit])
    assert_equal('false', result['params'][:pull_request])
    assert_equal('1', result['params'][:build])
    assert_equal('http://shippable.com/...', result['params'][:build_url])
    assert_equal('master', result['params'][:branch])
    assert_equal('owner/repo', result['params'][:slug])
    assert_equal('f881216b-b5c0-4eb1-8f21-b51887d1d506', result['params']['token'])
  end

  def test_appveyor
    ENV['CI'] = 'True'
    ENV['APPVEYOR'] = 'True'
    ENV['APPVEYOR_REPO_BRANCH'] = 'master'
    ENV['APPVEYOR_JOB_ID'] = 'build'
    ENV['APPVEYOR_PULL_REQUEST_NUMBER'] = '1'
    ENV['APPVEYOR_ACCOUNT_NAME'] = 'owner'
    ENV['APPVEYOR_PROJECT_SLUG'] = 'repo'
    ENV['APPVEYOR_BUILD_VERSION'] = 'job'
    ENV['APPVEYOR_REPO_NAME'] = 'owner/repo'
    ENV['APPVEYOR_REPO_COMMIT'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'
    result = upload
    assert_equal('appveyor', result['params'][:service])
    assert_equal('743b04806ea677403aa2ff26c6bdeb85005de658', result['params'][:commit])
    assert_equal('master', result['params'][:branch])
    assert_equal('owner/repo', result['params'][:slug])
    assert_equal('1', result['params'][:pr])
    assert_equal('build', result['params'][:build])
    assert_equal('owner/repo/job', result['params'][:job])
    assert_equal('f881216b-b5c0-4eb1-8f21-b51887d1d506', result['params']['token'])
  end

  def test_circleci
    ENV['CI'] = 'true'
    ENV['CIRCLECI'] = 'true'
    ENV['CIRCLE_BRANCH'] = 'master'
    ENV['CIRCLE_BUILD_NUM'] = '1'
    ENV['CIRCLE_NODE_INDEX'] = '2'
    ENV['CIRCLE_PR_NUMBER'] = '3'
    ENV['CIRCLE_PROJECT_USERNAME'] = 'owner'
    ENV['CIRCLE_PROJECT_REPONAME'] = 'repo'
    ENV['CIRCLE_SHA1'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'
    result = upload
    assert_equal('circleci', result['params'][:service])
    assert_equal('743b04806ea677403aa2ff26c6bdeb85005de658', result['params'][:commit])
    assert_equal('1', result['params'][:build])
    assert_equal('2', result['params'][:job])
    assert_equal('3', result['params'][:pr])
    assert_equal('master', result['params'][:branch])
    assert_equal('owner/repo', result['params'][:slug])
    assert_equal('f881216b-b5c0-4eb1-8f21-b51887d1d506', result['params']['token'])
  end

  def test_semaphore
    ENV['CI'] = 'true'
    ENV['SEMAPHORE'] = 'true'
    ENV['BRANCH_NAME'] = 'master'
    ENV['SEMAPHORE_REPO_SLUG'] = 'owner/repo'
    ENV['SEMAPHORE_BUILD_NUMBER'] = '1'
    ENV['SEMAPHORE_CURRENT_THREAD'] = '2'
    ENV['REVISION'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'
    result = upload
    assert_equal('semaphore', result['params'][:service])
    assert_equal('743b04806ea677403aa2ff26c6bdeb85005de658', result['params'][:commit])
    assert_equal('1', result['params'][:build])
    assert_equal('2', result['params'][:job])
    assert_equal('master', result['params'][:branch])
    assert_equal('owner/repo', result['params'][:slug])
    assert_equal('f881216b-b5c0-4eb1-8f21-b51887d1d506', result['params']['token'])
  end

  def test_drone
    ENV['CI'] = 'true'
    ENV['DRONE'] = 'true'
    ENV['DRONE_BRANCH'] = 'master'
    ENV['DRONE_BUILD_NUMBER'] = '1'
    ENV['DRONE_BUILD_URL'] = 'https://drone.io/...'
    ENV['DRONE_COMMIT'] = '1123566'
    ENV['CODECOV_SLUG'] = 'codecov/ci-repo'
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'
    result = upload
    assert_equal('drone.io', result['params'][:service])
    assert_equal(`git rev-parse HEAD`.strip, result['params'][:commit])
    assert_equal('1', result['params'][:build])
    assert_equal('https://drone.io/...', result['params'][:build_url])
    assert_equal('codecov/ci-repo', result['params'][:slug])
    assert_equal('master', result['params'][:branch])
    assert_equal('f881216b-b5c0-4eb1-8f21-b51887d1d506', result['params']['token'])
  end

  def test_wercker
    ENV['CI'] = 'true'
    ENV['WERCKER_GIT_BRANCH'] = 'master'
    ENV['WERCKER_MAIN_PIPELINE_STARTED'] = '1'
    ENV['WERCKER_GIT_OWNER'] = 'owner'
    ENV['WERCKER_GIT_REPOSITORY'] = 'repo'
    ENV['WERCKER_GIT_COMMIT'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'
    result = upload
    assert_equal('wercker', result['params'][:service])
    assert_equal('743b04806ea677403aa2ff26c6bdeb85005de658', result['params'][:commit])
    assert_equal('1', result['params'][:build])
    assert_equal('master', result['params'][:branch])
    assert_equal('owner/repo', result['params'][:slug])
    assert_equal('f881216b-b5c0-4eb1-8f21-b51887d1d506', result['params']['token'])
  end

  def test_gitlab
    ENV['GITLAB_CI'] = 'true'
    ENV['CI_BUILD_REF_NAME'] = 'master'
    ENV['CI_BUILD_ID'] = '1'
    ENV['CI_BUILD_REPO'] = 'https://gitlab.com/owner/repo.git'
    ENV['CI_BUILD_REF'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'
    result = upload
    assert_equal('gitlab', result['params'][:service])
    assert_equal('743b04806ea677403aa2ff26c6bdeb85005de658', result['params'][:commit])
    assert_equal('1', result['params'][:build])
    assert_equal('master', result['params'][:branch])
    assert_equal('owner/repo', result['params'][:slug])
    assert_equal('f881216b-b5c0-4eb1-8f21-b51887d1d506', result['params']['token'])
  end

  def test_bitrise
    ENV['CI'] = 'true'
    ENV['BITRISE_IO'] = 'true'
    ENV['BITRISE_BUILD_NUMBER'] = '1'
    ENV['BITRISE_BUILD_URL'] = 'https://app.bitrise.io/build/123'
    ENV['BITRISE_GIT_BRANCH'] = 'master'
    ENV['BITRISE_PULL_REQUEST'] = '2'
    ENV['BITRISEIO_GIT_REPOSITORY_OWNER'] = 'owner'
    ENV['BITRISEIO_GIT_REPOSITORY_SLUG'] = 'repo'
    ENV['BITRISE_GIT_COMMIT'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'
    result = upload
    assert_equal('bitrise', result['params'][:service])
    assert_equal('1', result['params'][:build])
    assert_equal('https://app.bitrise.io/build/123', result['params'][:build_url])
    assert_equal('master', result['params'][:branch])
    assert_equal('2', result['params'][:pr])
    assert_equal('owner/repo', result['params'][:slug])
    assert_equal('743b04806ea677403aa2ff26c6bdeb85005de658', result['params'][:commit])
  end

  def test_teamcity
    ENV['CI_SERVER_NAME'] = 'TeamCity'
    ENV['TEAMCITY_BUILD_BRANCH'] = 'master'
    ENV['TEAMCITY_BUILD_ID'] = '1'
    ENV['TEAMCITY_BUILD_URL'] = 'http://teamcity/...'
    ENV['TEAMCITY_BUILD_COMMIT'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV['TEAMCITY_BUILD_REPOSITORY'] = 'https://github.com/owner/repo.git'
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'
    result = upload
    assert_equal('teamcity', result['params'][:service])
    assert_equal('743b04806ea677403aa2ff26c6bdeb85005de658', result['params'][:commit])
    assert_equal('1', result['params'][:build])
    assert_equal('master', result['params'][:branch])
    assert_equal('owner/repo', result['params'][:slug])
    assert_equal('f881216b-b5c0-4eb1-8f21-b51887d1d506', result['params']['token'])
  end

  def test_azure_pipelines
    ENV['TF_BUILD'] = '1'
    ENV['BUILD_SOURCEBRANCH'] = 'master'
    ENV['SYSTEM_JOBID'] = '92a2fa25-f940-5df6-a185-81eb9ae2031d'
    ENV['BUILD_BUILDID'] = '1'
    ENV['SYSTEM_TEAMFOUNDATIONSERVERURI'] = 'https://dev.azure.com/codecov/'
    ENV['SYSTEM_TEAMPROJECT'] = 'repo'
    ENV['BUILD_SOURCEVERSION'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV['BUILD_REPOSITORY_ID'] = 'owner/repo'
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'
    result = upload
    assert_equal('azure_pipelines', result['params'][:service])
    assert_equal('743b04806ea677403aa2ff26c6bdeb85005de658', result['params'][:commit])
    assert_equal('1', result['params'][:build])
    assert_equal('master', result['params'][:branch])
    assert_equal('owner/repo', result['params'][:slug])
    assert_equal('f881216b-b5c0-4eb1-8f21-b51887d1d506', result['params']['token'])
  end

  def test_heroku
    ENV['HEROKU_TEST_RUN_ID'] = '454f5dc9-afa4-433f-bb28-84678a00fd98'
    ENV['HEROKU_TEST_RUN_BRANCH'] = 'master'
    ENV['HEROKU_TEST_RUN_COMMIT_VERSION'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'

    result = upload
    assert_equal('heroku', result['params'][:service])
    assert_equal('743b04806ea677403aa2ff26c6bdeb85005de658', result['params'][:commit])
    assert_equal('454f5dc9-afa4-433f-bb28-84678a00fd98', result['params'][:build])
    assert_equal('master', result['params'][:branch])
    assert_equal('f881216b-b5c0-4eb1-8f21-b51887d1d506', result['params']['token'])
  end

  def test_bitbucket_pr
    ENV['CI'] = 'true'
    ENV['BITBUCKET_BUILD_NUMBER'] = '100'
    ENV['BITBUCKET_BRANCH'] = 'master'
    ENV['BITBUCKET_COMMIT'] = '743b04806ea67'
    ENV['VCS_COMMIT_ID'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'

    result = upload
    assert_equal('bitbucket', result['params'][:service])
    assert_equal('743b04806ea677403aa2ff26c6bdeb85005de658', result['params'][:commit])
    assert_equal('100', result['params'][:build])
    assert_equal('master', result['params'][:branch])
    assert_equal('f881216b-b5c0-4eb1-8f21-b51887d1d506', result['params']['token'])
  end

  def test_bitbucket
    ENV['CI'] = 'true'
    ENV['BITBUCKET_BUILD_NUMBER'] = '100'
    ENV['BITBUCKET_BRANCH'] = 'master'
    ENV['BITBUCKET_COMMIT'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'

    result = upload
    assert_equal('bitbucket', result['params'][:service])
    assert_equal('743b04806ea677403aa2ff26c6bdeb85005de658', result['params'][:commit])
    assert_equal('100', result['params'][:build])
    assert_equal('master', result['params'][:branch])
    assert_equal('f881216b-b5c0-4eb1-8f21-b51887d1d506', result['params']['token'])
  end

  def test_filenames_are_shortened_correctly
    ENV['CODECOV_TOKEN'] = 'f881216b-b5c0-4eb1-8f21-b51887d1d506'

    formatter = SimpleCov::Formatter::Codecov.new
    result = stub('SimpleCov::Result', files: [
                    stub_file('/path/lib/something.rb', []),
                    stub_file('/path/path/lib/path_somefile.rb', [])
                  ])
    SimpleCov.stubs(:root).returns('/path')
    data = formatter.format(result)
    puts data
    puts data['params']
    assert_equal(data['coverage'].to_json, {
      'lib/something.rb' => [nil],
      'path/lib/path_somefile.rb' => [nil]
    }.to_json)
  end

  def test_invalid_token
    stub_request(:post, %r{https:\/\/codecov.io\/upload})
      .to_return(
        status: 400,
        body: "HTTP 400\n" \
              'Provided token is not a UUID.'
      )

    ENV['CODECOV_TOKEN'] = 'fake'
    result = upload(false)
    assert_equal(false, result['result']['uploaded'])
    branch = `git rev-parse --abbrev-ref HEAD`.strip
    assert_equal(branch != 'HEAD' ? branch : 'master', result['params'][:branch])
    assert_equal(`git rev-parse HEAD`.strip, result['params'][:commit])
  end
end
