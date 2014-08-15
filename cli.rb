#!/usr/bin/env ruby

require_relative 'baseball'

include Baseball

SEPARATOR = '-' * 80

# ----------------------------------
# load the data from the CSV sources
# ----------------------------------
Player.fetch!

# ------------------------------------------------
# Most improved batting average from 2009 to 2010.
# Only players with at least 200 at-bats.
# ------------------------------------------------
puts SEPARATOR
puts "Most improved batting average from 2009 to 2010 (min 200 at-bats)..."
puts SEPARATOR

ba = Player.most_improved_batting_average(2009, 2010, 200)
player = Player.find(ba[0])
printf "> #{player.first_name} #{player.last_name} showed the most improvement with %.2f%\n", ba[1]
puts

# ------------------------------------------------------
# Slugging percentage for all players on the Oakland A's
# (teamID = OAK) in 2007
# ------------------------------------------------------
puts SEPARATOR
puts "Slugging percentage for all players on the Oakland A's in 2007"
puts SEPARATOR

sp = Baseball::Player.slugging_performance('OAK', 2007)
sp.each do |player_id, perf|
  player = Player.find(player_id)
  printf "> #{player.first_name} #{player.last_name} with %.2f%\n", perf
end
puts

# --------------------------------------------
# triple crown winners for 2011/2012 for AL/NL
# --------------------------------------------

puts SEPARATOR
puts "Triple Crown Winners..."
puts SEPARATOR

LEAGUE_AND_YEAR = [['AL', 2011], ['AL', 2012], ['NL', 2011], ['NL', 2012]]
LEAGUE_AND_YEAR.each do |year_and_league|
  year = year_and_league[1]
  league = year_and_league[0]
  winner = Player.triple_crown_winner(league, year)
  message = ''

  if winner
    player = Player.find(winner)
    message = "#{player.first_name} #{player.last_name}"
  else
    message = "(No winner)"
  end

  puts "> Triple crown winner for #{league} in #{year} => #{message}"
end
puts SEPARATOR
