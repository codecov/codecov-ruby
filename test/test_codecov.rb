require 'helper'


class TestCodecov < Test::Unit::TestCase
  REALENV = {
    "TRAVIS_BRANCH" => ENV["TRAVIS_BRANCH"],
    "TRAVIS_COMMIT" => ENV["TRAVIS_COMMIT"],
    "TRAVIS_REPO_SLUG" => ENV['TRAVIS_REPO_SLUG'],
    "TRAVIS_JOB_NUMBER" => ENV['TRAVIS_JOB_NUMBER'],
    "TRAVIS_PULL_REQUEST" => ENV["TRAVIS_PULL_REQUEST"],
    "TRAVIS_JOB_ID" => ENV["TRAVIS_JOB_ID"],
    "TRAVIS_REPO_SLUG" => ENV["TRAVIS_REPO_SLUG"],
  }
  def url
    return ENV['CODECOV_URL'] || "https://codecov.io"
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
      stub('SimpleCov::SourceFile::Line', skipped?: skipped, line_number: i+1, coverage: cov)
    end
    stub('SimpleCov::SourceFile', filename: filename, lines: lines)
  end
  def upload
    formatter = SimpleCov::Formatter::Codecov.new
    result = stub('SimpleCov::Result', files: [
      stub_file('/path/lib/something.rb', [1, 0, 0, nil, 1, nil]),
      stub_file('/path/lib/somefile.rb', [1, nil, 1, 1, 1, 0, 0, nil, 1, nil]),
    ])
    SimpleCov.stubs(:root).returns('/path')
    data = formatter.format(result)
    assert_equal(data['result']['uploaded'], true)
    assert_equal(data['result']['message'], "Coverage reports upload successfully")
    assert_equal(data['meta']['version'], "codecov-python/v0.0.4")
    assert_equal(data['coverage'].to_json, {
      'lib/something.rb' => [nil, 1, 0, 0, nil, 1, nil],
      'lib/somefile.rb' => [nil, 1, nil, 1, 1, 1, 0, 0, nil, 1, nil]
    }.to_json)
    data
  end
  def setup
    ENV['CI'] = nil
    ENV['TRAVIS'] = nil
  end
  def teardown
    # needed for sending this projects coverage
    ENV['CI'] = "true"
    ENV['TRAVIS'] = "true"
    ENV['TRAVIS_BRANCH'] = REALENV["TRAVIS_BRANCH"]
    ENV['TRAVIS_COMMIT'] = REALENV["TRAVIS_COMMIT"]
    ENV['TRAVIS_JOB_NUMBER'] = REALENV["TRAVIS_JOB_NUMBER"]
    ENV['TRAVIS_REPO_SLUG'] = REALENV["TRAVIS_REPO_SLUG"]
    ENV['TRAVIS_PULL_REQUEST'] = REALENV["TRAVIS_PULL_REQUEST"]
    ENV['TRAVIS_JOB_ID'] = REALENV["TRAVIS_JOB_ID"]
    ENV['TRAVIS_REPO_SLUG'] = REALENV["TRAVIS_REPO_SLUG"]
    ENV['TRAVIS_TRAVIS_PULL_REQUEST'] = REALENV["TRAVIS_PULL_REQUEST"]
    ENV['CODECOV_TOKEN'] = nil
    ENV['CI_NAME'] = nil
    ENV['CIRCLECI'] = nil
    ENV['SEMAPHORE'] = nil
    ENV['DRONE'] = nil
    ENV["APPVEYOR"] = nil
    ENV["JENKINS_URL"] = nil
    ENV["SHIPPABLE"] = nil
    ENV["WERCKER_GIT_BRANCH"] = nil
  end
  def test_git
    ENV['CODECOV_TOKEN'] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
    result = upload
    assert_equal("473c8c5b-10ee-4d83-86c6-bfd72a185a27", result['params']['token'])
    branch = `git rev-parse --abbrev-ref HEAD`.strip
    assert_equal(branch != 'HEAD' ? branch : 'master', result['params'][:branch])
    assert_equal(`git rev-parse HEAD`.strip, result['params'][:commit])
  end
  def test_travis
    ENV['CI'] = 'true'
    ENV['TRAVIS'] = "true"
    ENV['TRAVIS_BRANCH'] = "master"
    ENV['TRAVIS_COMMIT'] = "c739768fcac68144a3a6d82305b9c4106934d31a"
    ENV['TRAVIS_JOB_ID'] = "33116958"
    ENV['TRAVIS_PULL_REQUEST'] = "1"
    ENV['TRAVIS_JOB_NUMBER'] = "1"
    ENV['TRAVIS_REPO_SLUG'] = "owner/repo"
    ENV['CODECOV_TOKEN'] = ''
    result = upload
    assert_equal("travis-org", result['params'][:service])
    assert_equal("c739768fcac68144a3a6d82305b9c4106934d31a", result['params'][:commit])
    assert_equal("owner", result['params'][:owner])
    assert_equal("repo", result['params'][:repo])
    assert_equal("1", result['params'][:build])
    assert_equal("33116958", result['params'][:travis_job_id])
    assert_equal('1', result['params'][:pull_request])
    assert_equal('', result['params']['token'])
  end
  def test_codeship
    ENV['CI'] = 'true'
    ENV['CI_NAME'] = 'codeship'
    ENV['CI_BRANCH'] = 'master'
    ENV['CI_BUILD_NUMBER'] = '1'
    ENV['CI_COMMIT_ID'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV['CODECOV_TOKEN'] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
    result = upload
    assert_equal("codeship", result['params'][:service])
    assert_equal("743b04806ea677403aa2ff26c6bdeb85005de658", result['params'][:commit])
    assert_equal("1", result['params'][:build])
    assert_equal("master", result['params'][:branch])
    assert_equal('473c8c5b-10ee-4d83-86c6-bfd72a185a27', result['params']['token'])
  end
  def test_shippable
    ENV['CI'] = "true"
    ENV["SHIPPABLE"] = 'true'
    ENV["BRANCH"] = 'master'
    ENV["BUILD_NUMBER"] = '1'
    ENV["BUILD_URL"] = 'http://shippable.com/...'
    ENV["PULL_REQUEST"] = '1'
    ENV["REPO_NAME"] = 'owner/repo'
    ENV["COMMIT"] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV["CODECOV_TOKEN"] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
    result = upload
    assert_equal("shippable", result['params'][:service], )
    assert_equal("743b04806ea677403aa2ff26c6bdeb85005de658", result['params'][:commit])
    assert_equal("1", result['params'][:pull_request])
    assert_equal("1", result['params'][:build])
    assert_equal('http://shippable.com/...', result['params'][:build_url])
    assert_equal("master", result['params'][:branch])
    assert_equal("owner", result['params'][:owner])
    assert_equal("repo", result['params'][:repo])
    assert_equal('473c8c5b-10ee-4d83-86c6-bfd72a185a27', result['params']['token'])
  end
  def test_appveyor
    ENV["CI"] = 'True'
    ENV["APPVEYOR"] = 'True'
    ENV["APPVEYOR_REPO_BRANCH"] = 'master'
    ENV["APPVEYOR_BUILD_NUMBER"] = '1'
    ENV["APPVEYOR_REPO_NAME"] = 'owner/repo'
    ENV["APPVEYOR_REPO_COMMIT"] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV["CODECOV_TOKEN"] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
    result = upload
    assert_equal("appveyor", result['params'][:service], )
    assert_equal("743b04806ea677403aa2ff26c6bdeb85005de658", result['params'][:commit], )
    assert_equal("1", result['params'][:build])
    assert_equal("master", result['params'][:branch])
    assert_equal("owner", result['params'][:owner])
    assert_equal("repo", result['params'][:repo])
    assert_equal('473c8c5b-10ee-4d83-86c6-bfd72a185a27', result['params']['token'])
  end
  def test_circleci
    ENV['CI'] = 'true'
    ENV['CIRCLECI'] = 'true'
    ENV['CIRCLE_BRANCH'] = "master"
    ENV['CIRCLE_BUILD_NUM'] = "1"
    ENV['CIRCLE_PROJECT_USERNAME'] = "owner"
    ENV['CIRCLE_PROJECT_REPONAME'] = "repo"
    ENV['CIRCLE_SHA1'] = "743b04806ea677403aa2ff26c6bdeb85005de658"
    ENV['CODECOV_TOKEN'] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
    result = upload
    assert_equal("circleci", result['params'][:service], )
    assert_equal("743b04806ea677403aa2ff26c6bdeb85005de658", result['params'][:commit], )
    assert_equal("1", result['params'][:build])
    assert_equal("master", result['params'][:branch])
    assert_equal("owner", result['params'][:owner])
    assert_equal("repo", result['params'][:repo])
    assert_equal('473c8c5b-10ee-4d83-86c6-bfd72a185a27', result['params']['token'])
  end
  def test_semaphore
    ENV['CI'] = 'true'
    ENV['SEMAPHORE'] = "true"
    ENV['BRANCH_NAME'] = "master"
    ENV['SEMAPHORE_REPO_SLUG'] = 'owner/repo'
    ENV['SEMAPHORE_BUILD_NUMBER'] = "1"
    ENV['REVISION'] = "743b04806ea677403aa2ff26c6bdeb85005de658"
    ENV['CODECOV_TOKEN'] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
    result = upload
    assert_equal("semaphore", result['params'][:service], )
    assert_equal("743b04806ea677403aa2ff26c6bdeb85005de658", result['params'][:commit], )
    assert_equal("1", result['params'][:build])
    assert_equal("master", result['params'][:branch])
    assert_equal("owner", result['params'][:owner])
    assert_equal("repo", result['params'][:repo])
    assert_equal('473c8c5b-10ee-4d83-86c6-bfd72a185a27', result['params']['token'])
  end
  def test_drone
    ENV['CI'] = "true"
    ENV['DRONE'] = "true"
    ENV['DRONE_BRANCH'] = "master"
    ENV['DRONE_BUILD_NUMBER'] = "1"
    ENV['DRONE_BUILD_URL'] = "https://drone.io/..."
    ENV['DRONE_COMMIT'] = "743b04806ea677403aa2ff26c6bdeb85005de658"
    ENV['CODECOV_TOKEN'] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
    result = upload
    assert_equal("drone.io", result['params'][:service], )
    assert_equal("743b04806ea677403aa2ff26c6bdeb85005de658", result['params'][:commit], )
    assert_equal("1", result['params'][:build])
    assert_equal("https://drone.io/...", result['params'][:build_url])
    assert_equal("master", result['params'][:branch])
    assert_equal('473c8c5b-10ee-4d83-86c6-bfd72a185a27', result['params']['token'])
  end
  def test_wercker
    ENV['CI'] = "true"
    ENV['WERCKER_GIT_BRANCH'] = "master"
    ENV['WERCKER_MAIN_PIPELINE_STARTED'] = "1"
    ENV['WERCKER_GIT_OWNER'] = "owner"
    ENV['WERCKER_GIT_REPOSITORY'] = "repo"
    ENV['WERCKER_GIT_COMMIT'] = "743b04806ea677403aa2ff26c6bdeb85005de658"
    ENV['CODECOV_TOKEN'] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
    result = upload
    assert_equal("wercker", result['params'][:service], )
    assert_equal("743b04806ea677403aa2ff26c6bdeb85005de658", result['params'][:commit], )
    assert_equal("1", result['params'][:build])
    assert_equal("master", result['params'][:branch])
    assert_equal("owner", result['params'][:owner])
    assert_equal("repo", result['params'][:repo])
    assert_equal('473c8c5b-10ee-4d83-86c6-bfd72a185a27', result['params']['token'])
  end
end
