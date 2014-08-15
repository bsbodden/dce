# This module (Baseball) contains a single class; Player which represents a
# Player along with a collection of stats (a one two many). The class uses Hashie
# so that objects can be simply constructed out of a Hash but exhibit behavior
# similar to models in a framework or well-form POROs.
# Obviously the best thing would have been to import the data into a relational
# database to have the ability to slice and dice it at will. But I imagine that's
# not the point of the exercise.
# I made the Baseball class as close to a ActiveModel instance as possible (without
# actually implementing ActiveModel) in order to provide an easy transition to a
# web based environment, simplify testing and better encapsulate the provided data.
# The reading of the data is also baked into the class in a fetch! method which takes
# care of doing some transformations on the data also.
# Some basic building block operations are also baked into the class, as well as
# the other higher level operations (which would more likely be in service object
# or even in a controller) for convenience (my convenience)

require 'rubygems'
require 'hashie'
require 'csv'

module Baseball
  class Player < Hashie::Mash
    MASTER_FILE = './data/Master-small.csv'
    BATTING_FILE = './data/Batting-07-12.csv'

    MASTER_FIELDS = { id: 0, birth_year: 1, first_name: 2, last_name: 3 }
    BATTING_FIELDS = { id: 0, year: 1, league: 2, team: 3, G: 4, AB: 5, R: 6,
                       H: 7, SECONDB: 8, THIRDB: 9, HR: 10 , RBI: 11, SB: 12, CS: 13 }
    # field to convert to floats (since we'll be doing some math)
    BATTING_FIELDS_TO_F = [:year, :G, :AB, :R, :H, :SECONDB, :THIRDB, :HR, :RBI, :SB, :CS]

    # load players and stats from CSV files and handle datatype conversions
    def self.fetch!
      @@data = {}

      fetch_rows(MASTER_FILE, MASTER_FIELDS) do |values_keyed|
        player = self.new(values_keyed)
        player.stats = []
        @@data[player.id] = player
      end

      fetch_rows(BATTING_FILE, BATTING_FIELDS, BATTING_FIELDS_TO_F) do |values_keyed|
        @@data[values_keyed[:id]].stats << Hashie::Mash.new(values_keyed)
      end

      @@data.size > 0
    end

    def self.all
      @@data.values || []
    end

    def self.find(id)
      @@data[id]
    end

    def batting_average(year, at_bats_min = 0, league = nil)
      if stats
        stat = stats.select { |stat| (stat.year == year) && (stat.AB > at_bats_min) && (league.nil? ? true : stat.league == league)}.first
        stat.nil? ? nil : stat.H / stat.AB
      else
        nil
      end
    end

    def batting_average_improvement(from, to, at_bats_min = 0)
      from_ba = batting_average(from, at_bats_min)
      to_ba = batting_average(to, at_bats_min)

      if !to_ba.nil? && !from_ba.nil? && to_ba > 0
        (to_ba - from_ba) / to_ba * 100
      else
        nil
      end
    end

    #
    # Class methods
    #

    def self.most_improved_batting_average(from, to, at_bats_min = 0)
      percent_improvements = Hash[all.map{ |p| [p.id, p.batting_average_improvement(from, to, at_bats_min)]}]
      percent_improvements = percent_improvements.keep_if { |k,v| !v.nil? && v != -Float::INFINITY && !v.nan? }

      percent_improvements.max_by { |k, v| v }
    end

    # extract to a Team class (collection of players if more functionality required around teams)
    def self.slugging_performance(team, year)
      results = {}
      stats = stats_filtered_by({team: team, year: year})
      stats.each do |s|
        percentage = ((s.H - s.SECONDB - s.THIRDB - s.HR) + (2 * s.SECONDB) + (3 * s.THIRDB) + (4 * s.HR)) / s.AB
        results[s.id] = percentage unless percentage.nan?
      end
      results
    end

    # The player that had the highest batting average AND the most home runs AND the most RBI in their league.
    def self.triple_crown_winner(league, year, at_bats_min = 400.0)
      stats = stats_filtered_by({league: league, year: year})
      max_by_ba = stats.max_by { |s| ba = s.H / s.AB; ba.nan? || s.AB < at_bats_min ? 0 : ba }.id
      max_by_hr = stats.max_by { |s| s.HR }.id
      max_by_rbi = stats.max_by { |s| s.RBI }.id

      [max_by_ba, max_by_hr, max_by_rbi].uniq.size == 1 ? max_by_ba : nil
    end

    private

    #
    def self.fetch_rows(file, fields, to_f_fields = nil)
      rows = CSV.read(file)
      rows.shift

      rows.each do |row|
        values_keyed = Hash[fields.keys.map { |sym| [sym, row[fields[sym]]] }]
        if to_f_fields
          values_keyed = values_keyed.inject({}) do |h, (k, v)|
            h[k] = to_f_fields.include?(k) ? v.to_f : v ; h
          end
        end
        yield(values_keyed)
      end
    end

    # pass a hash of filters like { :league => 'AL', :year => 2011 }
    # filters are ANDed together
    def self.stats_filtered_by(filters)
      all.map(&:stats).flatten.keep_if do |s|
        keep = true
        filters.each do |key, value|
          keep = keep && s.send(key) == value
        end

        keep
      end
    end

  end
end
