require 'helper'

class TestCodecov < Test::Unit::TestCase
  def url
    return ENV['CODECOV_URL'] || "https://codecov.io"
  end
  def test_defined
    assert defined?(SimpleCov::Formatter::Codecov)
    assert defined?(SimpleCov::Formatter::Codecov::VERSION)
  end
  def passes
    formatter = SimpleCov::Formatter::Codecov.new
    result = mock()
    something = mock()
    somefile = mock()
    something.expects(:filename).twice.returns('/lib/something.rb')
    something.expects(:lines_of_code).returns(6)
    something.expects(:coverage).returns([nil, 1, 0, 0, nil, 1, nil])
    somefile.expects(:filename).twice.returns('/lib/somefile.rb')
    somefile.expects(:lines_of_code).returns(10)
    somefile.expects(:coverage).returns([nil, 1, nil, 1, 1, 1, 0, 0, nil, 1, nil])
    result.expects(:files).returns([something, somefile])
    result.expects(:filenames).twice.returns(['/lib/something.rb', '/lib/somefile.rb'])
    data = formatter.format(result)
    assert_equal(data['result']['uploaded'], true)
    assert_match(/\/github\/codecov\/ci\-repo\?ref\=[a-z\d]{40}$/, data['result']['url'])
    assert_equal(data['result']['message'], "Coverage reports upload successfully")
    assert_equal(data['meta']['version'], "codecov-python/v0.0.1")
    assert_equal(data['coverage'].to_json, {
      '/lib/something.rb' => [nil, 1, 0, 0, nil, 1, nil],
      '/lib/somefile.rb' => [nil, 1, nil, 1, 1, 1, 0, 0, nil, 1, nil]
    }.to_json)
    return true
  end
  def test_git
    ENV['CI'] = nil
    ENV['CODECOV_TOKEN'] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
    assert_equal(passes, true)
  end
  def test_travis
    ENV['CI'] = "true"
    ENV['TRAVIS'] = "true"
    ENV['TRAVIS_BRANCH'] = "master"
    ENV['TRAVIS_COMMIT'] = "c739768fcac68144a3a6d82305b9c4106934d31a"
    ENV['TRAVIS_JOB_ID'] = "33116958"
    assert_equal(passes, true)
  end
  def test_codeship
      ENV['CI'] = "true"
      ENV['CI_NAME'] = 'codeship'
      ENV['CI_BRANCH'] = 'master'
      ENV['CI_COMMIT_ID'] = '743b04806ea677403aa2ff26c6bdeb85005de658'
      ENV['CODECOV_TOKEN'] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
      assert_equal(passes, true)
  end
  def test_circleci
      ENV['CI'] = "true"
      ENV['CIRCLECI'] = 'true'
      ENV['CIRCLE_BRANCH'] = "master"
      ENV['CIRCLE_SHA1'] = "743b04806ea677403aa2ff26c6bdeb85005de658"
      ENV['CODECOV_TOKEN'] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
      assert_equal(passes, true)
  end
  def test_semaphore
      ENV['CI'] = "true"
      ENV['SEMAPHORE'] = "true"
      ENV['BRANCH_NAME'] = "master"
      ENV['SEMAPHORE_PROJECT_HASH_ID'] = "743b04806ea677403aa2ff26c6bdeb85005de658"
      ENV['CODECOV_TOKEN'] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
      assert_equal(passes, true)
  end
  def test_drone
      ENV['CI'] = "true"
      ENV['DRONE'] = "true"
      ENV['DRONE_BRANCH'] = "master"
      ENV['DRONE_COMMIT'] = "743b04806ea677403aa2ff26c6bdeb85005de658"
      ENV['CODECOV_TOKEN'] = '473c8c5b-10ee-4d83-86c6-bfd72a185a27'
      assert_equal(passes, true)
  end
end
