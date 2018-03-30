require 'json'
require 'rss'
require 'cgi'

abort 'Version db or branch missing.' if ARGV.size < 2

version_raw = File.read ARGV[0]
version = JSON.parse(version_raw)

branch = ARGV[1]

abort "Branch is neither public or beta." unless [ "public", "beta" ].include? branch

rss = RSS::Maker.make("atom") do |m|
  m.channel.author = "Melair"
  m.channel.updated = Time.now
  m.channel.about = "http://stationeers.melaircraft.net"
  m.channel.title = "Stationeers Version History - Branch: #{branch}"

  versions = version.keys.select { |k| version[k]["releases"].has_key? branch }[0,10]

  versions.each do |v|
    m.items.new_item do |item|
      item.id = "urn:stationeers_version:#{v}"
      item.title = v
      item.content.type = "xhtml"

      representation = version[v]["notes"].map { |l| "<li>#{CGI.escapeHTML(l)}</li>" }.join("")

      built_at_raw = version[v]["releases"]["built"]

      if built_at_raw.nil? || built_at_raw == "unknown"
        built_at = "Unknown"
      else
        built_at = Time.parse(built_at_raw).strftime('%Y-%m-%d')
      end

      item.content.xml_content = "<p>Originally Built: #{built_at}</p><ul>#{representation}</ul>"

      release_date = version[v]["releases"][branch]

      unless release_date == "unknown"
        item.updated = Time.parse(release_date)
      else
        item.updated = Time.parse("2018-01-01")
      end
    end
  end
end

puts rss
