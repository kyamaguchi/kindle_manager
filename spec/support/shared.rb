def find_fixture_filepath(name)
  path = File.join('spec', 'fixtures', 'files', name)
  pending("Put your html in #{path} for testing") unless File.exist?(path)
  path
end
