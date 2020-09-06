
require 'yaml'

module FlutterUtils
  def self._config_path
    return Dir.pwd + '/../../pubspec.yaml'
  end

  def self._load_pubspec
    return YAML.load_file(_config_path())
  end

  def self._parse_version(pubspec)
    version_str = pubspec['version']
    sections = version_str.split('+')
    if sections.length() != 2
      raise "Malformed flutter version string #{version_str}"
    end
    return sections
  end

  # Returns build number e.g. 12
  def self.version
    pubspec = _load_pubspec()
    sections = _parse_version(pubspec)
    return sections[1].to_i
  end

  # Returns string version, e.g. 2.0.3
  def self.version_name
    pubspec = _load_pubspec()
    sections = _parse_version(pubspec)
    return sections[0]
  end

  def self.bump_version
    pubspec = _load_pubspec()
    sections = _parse_version(pubspec)
    old_version_str = "#{sections[0]}+#{sections[1]}"
    new_version = sections[1].to_i + 1
    new_version_str = "2.0.#{new_version}+#{new_version}"
    text = File.open(_config_path()).read()
    if text.gsub!(old_version_str, new_version_str) == nil
      raise "Error editing pubspec.yaml, could not replace #{old_version_str} with #{new_version_str}"
    end
    File.open(_config_path(), 'w') do |out|
      out.write(text)
    end
    system("git", "commit", "-m", "Prepare to release #{new_version_str}",
           _config_path(), exception: true)
    return new_version
  end
end

