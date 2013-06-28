module NBA
  module Cache
    def write_cache(path, response)
      # raise DownloadFailed, path unless response.success?
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') { |f| f << response.body }
    end

    def read_cached_file(path)
      raise Error unless File.exist? path
      JSON.parse(File.read(path))
      rescue
        File.delete(path) if File.exist? path
        puts "Missing file: #{path}"
        {}
    end

  end
end
