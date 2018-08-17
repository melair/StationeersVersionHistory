require 'json'
require 'time'

abort 'No version filename provided.' if ARGV.size < 1

raw = File.read ARGV[0]

NOTES_SPLIT_MARKER = 'UPDATENOTES='
LINE_BREAK = /[\r]?\n/
VALUE_SEPERATOR = '='

version_raw, notes_raw = raw.split NOTES_SPLIT_MARKER

VERSION_KEY = "UPDATEVERSION"
RELEASE_KEY = "UPDATEDATE"

def parse_version_data version_raw
  version_lines = version_raw.split LINE_BREAK
  version_hash = version_lines.map { |line| line.split VALUE_SEPERATOR }.to_h

  clean_version = extract_version version_hash[VERSION_KEY]
  clean_time = Time.parse version_hash[RELEASE_KEY]

  { "version" => clean_version, "date" => clean_time.iso8601 }
end

VERSION_REGEX = /(Version|Update) (\d+.\d+.\d+.\d+)/

def extract_version text
  match = VERSION_REGEX.match(text)

  return nil if match.nil?

  match[2]
end

version_data = parse_version_data version_raw

NOTE_HEADER_REGEX = /^(.*Version \d+.\d+.\d+.\d+.*)$/

def parse_release_notes notes_raw
  split_notes_raw = notes_raw.split NOTE_HEADER_REGEX
  split_notes_raw.shift if split_notes_raw[0].empty?

  abort "Uneven notes section!" if split_notes_raw.length % 2 != 0

  notes = []

  split_notes_raw.each_slice(2) do |data|

    note_version = extract_version data[0]
    notes_for_version = extract_notes data[1]

    notes << { "version" => note_version, "notes" => notes_for_version }
  end

  notes
end

PREPENDED_NOISE_REGEX = /\s?[-]?\s?/
REMOVE_HTML_LIKE_REGEX = /<.*>(.*)<.*>/

def extract_notes raw_notes
  raw_notes.split(LINE_BREAK).select { |l| !l.empty? }.map { |l| l.sub PREPENDED_NOISE_REGEX, '' }.map { |l| l.gsub REMOVE_HTML_LIKE_REGEX, '\1' }.map { |l| l.rstrip }
end

notes = parse_release_notes notes_raw

top_note = notes[0]

top_note["notes"] = ["*** https://stationeers.melaircraft.com is being decomissioned, please see https://stationeering.com/tools/data for a replacement feed. ***"] + top_note["notes"]

notes[0] = top_note

all = { "current" => version_data, "history" => notes }

puts JSON.pretty_generate(all)
