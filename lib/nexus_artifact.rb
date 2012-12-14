
require 'yaml'
require 'mechanize'
require 'digest/sha1'
require "nexus_artifact/version"

class NexusArtifact

  PATTERN_MAP = {
    '%v' => :ver,
    '%e' => :ext,
  }

  def self.instance
    @instance ||= begin
      yml = YAML.load File.read('nexus.yml')
      obj = new yml[:uri], yml[:path], yml[:artifact]
      if yml[:user] && yml[:pass]
        obj.auth yml[:user], yml[:pass]
      end
      obj
    end
  end

  attr_reader :agent, :base_uri, :base_href, :pattern

  def initialize(base_uri, base_path, pattern)
    @base_uri = base_uri
    @base_href = "#{base_uri}#{base_path}"
    @pattern = pattern
    @agent = Mechanize.new
  end

  def auth(user, pass)
    agent.add_auth(base_uri, user, pass)
    self
  end

  def versions
    pg = call(:get, '') or return []
    pg.links.map do |link|
      link.text.gsub('/', '') if link.href.start_with? base_href
    end.compact
  end

  def builds(base)
    versions.map do |v|
      $1.to_i if v.start_with?(base) && v[base.size .. -1] =~ /\A\.(\d+)\Z/
    end.compact.sort
  end

  def next_version(base)
    max = builds(base).max || -1
    "#{base}.#{max + 1}"
  end

  def get(file, data)
    path = path(data)
    sha1_expected = call(:get_file, path + '.sha1').to_s.strip
    download(path, file)
    sha1_actual = Digest::SHA1.file(file).hexdigest
    if sha1_expected != sha1_actual
      raise "SHA1 mismatch for #{file}.  Expected #{sha1_expected.inspect} but got #{sha1_actual.inspect}."
    end
  end

  def publish(file, data)
    path = path(data)
    uploads = [
      [path, File.read(file)],
      [path + '.sha1', Digest::SHA1.file(file).hexdigest],
      ([path + '.git', data[:git]] if data[:git]),
    ]
    uploads.each do |path, contents|
      raise "#{path} already exists" if call(:head, path)
    end
    uploads.each do |path, contents|
      call(:put, path, contents)
    end
    nil
  end

  private

  def path(data)
    "/#{pattern}".tap do |path|
      PATTERN_MAP.each do |sym, key|
        path.gsub! sym, data[key]
      end
    end
  end

  def call(method, path, *args)
    agent.send method, "#{base_href}#{path}", *args
  rescue Mechanize::ResponseCodeError => e
    raise e unless '404' == e.response_code
  end

  def download(path, dest)
    prior = agent.pluggable_parser.default
    agent.pluggable_parser.default = Mechanize::Download
    File.unlink(dest) # Delete or else it will be saved in #{file}.1
    call(:get, path).save(dest)
  ensure
    agent.pluggable_parser.default = prior
  end

end
