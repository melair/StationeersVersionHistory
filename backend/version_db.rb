require 'json'
require 'time'

abort 'History, version db or branch missing.' if ARGV.size < 3

# Read the parsed version data from Stationeers.
history_raw = File.read ARGV[0]
history = JSON.parse(history_raw)

# Load our JSON version database if it exists.
if File.exists?(ARGV[1])
  version_raw = File.read ARGV[1]
  version = JSON.parse(version_raw)
else
  version = {}
end

branch = ARGV[2]

abort "Branch is neither public or beta." unless [ "public", "beta" ].include? branch

# For each version in our parsed patch log, add it to the version store if it
# is not present.
history["history"].each do |release|
  release_version = release["version"]

  # Add version to the database if it's not present, adding notes. We also do
  # not known when it was built.
  unless version.has_key? release_version
    version[release_version] = { "notes" => release["notes"], "releases" => { "built" => "unknown" } }
  end

  # If this is the first time we have seen this history release, then mark it
  # as on the branch, but with an unknown start time.
  unless version[release_version]["releases"].has_key? branch
    version[release_version]["releases"][branch] = "unknown"
  end
end

current = history["current"]
release_version = current["version"]

# Check to see if the current version is in the history, if it's not then it's
# a release without any patch notes.
unless version.has_key? release_version
  version[release_version] = { "notes" => [ ], "releases" => { "built" => "unknown" } }
end

# If this is the first time this branch has been seen then set it to an unknown
# date.
unless version[release_version]["releases"].has_key? branch
  version[release_version]["releases"][branch] = "unknown"
end

# Use the date the release date from the patch notes for the current version.
version[release_version]["releases"]["built"] = current["date"]

# If the release time for this branch is unknown set this now. We do this
# seperately to the above, as the above only kicks in if it's a new release
# without any notes.
if version[release_version]["releases"][branch] == "unknown"
  version[release_version]["releases"][branch] = Time.now.iso8601
end

# Turn a quad version into a number, for ordering purposes.
def ver_to_i version
  split_version = version.split "."
  major = split_version[0].to_i
  minor = split_version[1].to_i
  patch = split_version[2].to_i
  build = split_version[3].to_i

  build + (patch * 10000) + (minor * 100000000) + (major * 1000000000000)
end

# Sort the version list in reverse, this would not have worked prior to Ruby
# 1.9, as that's when hash keys became ordered.
version_sorted = version.sort { |a,b| ver_to_i(a[0]) <=> ver_to_i(b[0]) } .reverse.to_h

# Output and write nice JSON.
version_json = JSON.pretty_generate(version_sorted)
File.write(ARGV[1], version_json)
