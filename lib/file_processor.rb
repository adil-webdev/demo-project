class FileProcessor
  UPLOAD_DIR = "uploads"
  ALLOWED_EXTENSIONS = %w[.jpg .jpeg .png .gif .pdf].freeze
  MAX_FILE_SIZE = 10_000_000

  def self.validate_file(file)
    return { valid: false, error: "File is nil" } if file.nil?
    return { valid: false, error: "File too large" } if file.size > MAX_FILE_SIZE
    return { valid: false, error: "File too small" } if file.size < 1

    extension = File.extname(file.original_filename).downcase

    unless ALLOWED_EXTENSIONS.include?(extension)
      return { valid: false, error: "Invalid file type: #{extension}" }
    end

    { valid: true }
  end

  def self.safe_read(filename)
    sanitized = File.basename(filename)
    filepath = File.join(UPLOAD_DIR, sanitized)

    raise "File not found: #{sanitized}" unless File.exist?(filepath)

    File.read(filepath)
  end

  def self.safe_delete(filename)
    sanitized = File.basename(filename)
    filepath = File.join(UPLOAD_DIR, sanitized)

    File.delete(filepath) if File.exist?(filepath)
  end
end
