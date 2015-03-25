require 'helper'


class TestCodecov < Test::Unit::TestCase
  REALENV = {
    "TRAVIS_BRANCH" => ENV["TRAVIS_BRANCH"],
    "TRAVIS_COMMIT" => ENV["TRAVIS_COMMIT"],
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
  def passes
    formatter = SimpleCov::Formatter::Codecov.new
    result = stub('SimpleCov::Result', files: [
      stub_file('/path/lib/something.rb', [1, 0, 0, nil, 1, nil]),
      stub_file('/path/lib/somefile.rb', [1, nil, 1, 1, 1, 0, 0, nil, 1, nil]),
    ])
    SimpleCov.stubs(:root).returns('/path')
    data = formatter.format(result)
    assert_equal(data['result']['uploaded'], true)
    assert_equal(data['result']['message'], "Coverage reports upload successfully")
    assert_equal(data['meta']['version'], "codecov-python/v0.0.3")
    assert_equal(data['coverage'].to_json, {
      'lib/something.rb' => [nil, 1, 0, 0, nil, 1, nil],
      'lib/somefile.rb' => [nil, 1, nil, 1, 1, 1, 0, 0, nil, 1, nil]
    }.to_json)
    return true
  end
  def setup
    ENV['CI'] = "true"
    ENV['CODECOV_TOKEN'] = nil
    # travis
    ENV['TRAVIS'] = nil
    ENV['CI_NAME'] = nil
    ENV['CIRCLECI'] = nil
    ENV['SEMAPHORE'] = nil
    ENV['DRONE'] = nil
    ENV["APPVEYOR"] = nil
    ENV["SHIPPABLE"] = nil
    ENV["WERCKER_GIT_BRANCH"] = nil
  end
  def teardown
    # needed for sending this projects coverage
    ENV['CI'] = "true"
    ENV['TRAVIS'] = "true"
    ENV['TRAVIS_BRANCH'] = REALENV["TRAVIS_BRANCH"]
    ENV['TRAVIS_COMMIT'] = REALENV["TRAVIS_COMMIT"]
    ENV['TRAVIS_JOB_ID'] = REALENV["TRAVIS_JOB_ID"]
    ENV['TRAVIS_REPO_SLUG'] = REALENV["TRAVIS_REPO_SLUG"]
    ENV['TRAVIS_TRAVIS_PULL_REQUEST'] = REALENV["TRAVIS_PULL_REQUEST"]
    ENV['CODECOV_TOKEN'] = nil
  end
  def test_git
    ENV['CI'] = nil
    ENV['CODECOV_TOKEN'] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
    assert_equal(passes, true)
  end
  def test_travis
    ENV['TRAVIS'] = "true"
    ENV['TRAVIS_BRANCH'] = "master"
    ENV['TRAVIS_COMMIT'] = "c739768fcac68144a3a6d82305b9c4106934d31a"
    ENV['TRAVIS_JOB_ID'] = "33116958"
    ENV['TRAVIS_REPO_SLUG'] = "owner/repo"
    assert_equal(passes, true)
  end
  def test_codeship
    ENV['CI_NAME'] = 'codeship'
    ENV['CI_BRANCH'] = 'master'
    ENV['CI_COMMIT_ID'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    ENV['CODECOV_TOKEN'] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
    assert_equal(passes, true)
  end
  def test_shippable
    ENV["SHIPPABLE"] = 'true'
    ENV["BRANCH"] = 'master'
    ENV["BUILD_NUMBER"] = '1'
    ENV["BUILD_URL"] = 'http://shippable.com/...'
    ENV["PULL_REQUEST"] = '1'
    ENV["REPO_NAME"] = 'owner/repo'
    ENV["COMMIT"] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    assert_equal(passes, true)
  end
  def test_appveyor
    ENV["CI"] = 'True'
    ENV["APPVEYOR"] = 'True'
    ENV["APPVEYOR_REPO_BRANCH"] = 'master'
    ENV["APPVEYOR_BUILD_NUMBER"] = '1'
    ENV["APPVEYOR_REPO_NAME"] = 'owner/repo'
    ENV["APPVEYOR_REPO_COMMIT"] = '743b04806ea677403aa2ff26c6bdeb85005de658'
    assert_equal(passes, true)
  end
  def test_circleci
    ENV['CIRCLECI'] = 'true'
    ENV['CIRCLE_BRANCH'] = "master"
    ENV['CIRCLE_BUILD_NUM'] = "1"
    ENV['CIRCLE_PROJECT_USERNAME'] = "owner"
    ENV['CIRCLE_PROJECT_REPONAME'] = "repo"
    ENV['CIRCLE_SHA1'] = "743b04806ea677403aa2ff26c6bdeb85005de658"
    ENV['CODECOV_TOKEN'] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
    assert_equal(passes, true)
  end
  def test_semaphore
    ENV['SEMAPHORE'] = "true"
    ENV['BRANCH_NAME'] = "master"
    ENV['SEMAPHORE_REPO_SLUG'] = 'repo/owner'
    ENV['SEMAPHORE_BUILD_NUMBER'] = '1'
    ENV['REVISION'] = "743b04806ea677403aa2ff26c6bdeb85005de658"
    ENV['CODECOV_TOKEN'] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
    assert_equal(passes, true)
  end
  def test_drone
    ENV['DRONE'] = "true"
    ENV['DRONE_BRANCH'] = "master"
    ENV['DRONE_BUILD_URL'] = "https://drone.io/..."
    ENV['DRONE_COMMIT'] = "743b04806ea677403aa2ff26c6bdeb85005de658"
    ENV['CODECOV_TOKEN'] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
    assert_equal(passes, true)
  end
  def test_wercker
    ENV['WERCKER_GIT_BRANCH'] = "master"
    ENV['WERCKER_MAIN_PIPELINE_STARTED'] = "1"
    ENV['WERCKER_GIT_OWNER'] = "owner"
    ENV['WERCKER_GIT_REPOSITORY'] = "repo"
    ENV['WERCKER_GIT_COMMIT'] = "743b04806ea677403aa2ff26c6bdeb85005de658"
    ENV['CODECOV_TOKEN'] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
    assert_equal(passes, true)
  end
end
