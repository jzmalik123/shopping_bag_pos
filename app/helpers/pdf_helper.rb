module PdfHelper
  def pdf_logo_src
    explicit = ENV["PDF_LOGO_PATH"].to_s.strip
    return "file://#{explicit}" if explicit.present? && File.exist?(explicit)

    candidates = [
      Rails.root.join("public", "logo_with_tagline.png"),
      Rails.root.join("public", "logo_with_tagline.jpg"),
      Rails.root.join("public", "logo_with_tagline.jpeg"),
      Rails.root.join("public", "logo_with_tagline.webp"),
      Rails.root.join("app", "assets", "images", "logo_with_tagline.png"),
      Rails.root.join("app", "assets", "images", "logo_with_tagline.jpg"),
      Rails.root.join("app", "assets", "images", "logo_with_tagline.jpeg"),
      Rails.root.join("app", "assets", "images", "logo_with_tagline.webp")
    ]

    logo_path = candidates.find { |path| File.exist?(path) }
    logo_path.present? ? "file://#{logo_path}" : nil
  end
end
module PdfHelper
  def pdf_logo_file_path
    candidates = []

    env_logo = ENV["PDF_LOGO_PATH"].to_s.strip
    candidates << Pathname.new(env_logo) unless env_logo.empty?

    logo_names = [
      "logo_with_tagline.png",
      "logo_with_tagline.jpg",
      "logo_with_tagline.jpeg",
      "logo_with_tagline.webp",
      "logo.png",
      "logo.jpg",
      "logo.jpeg",
      "logo.webp"
    ]

    logo_names.each do |name|
      candidates << Rails.root.join("public", name)
      candidates << Rails.root.join("app", "assets", "images", name)
    end

    assets_dir = Rails.root.join("public", "assets")
    if Dir.exist?(assets_dir)
      logo_globs = [
        "logo_with_tagline*",
        "logo*"
      ]
      logo_globs.each do |pattern|
        Dir.glob(assets_dir.join(pattern).to_s).each do |asset_path|
          candidates << Pathname.new(asset_path)
        end
      end
    end

    existing = candidates.find { |path| File.exist?(path) && !File.directory?(path) }
    existing ? "file://#{existing}" : nil
  end
end
