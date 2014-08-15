# Baseball Player Stats

[![Code Climate](https://codeclimate.com/github/bsbodden/dce/badges/gpa.svg)](https://codeclimate.com/github/bsbodden/dce)

## Purpose

It provides:
1. Most improved batting average( hits / at-bats) from 2009 to 2010.
   Only include players with at least 200 at-bats.
2. Slugging percentage for all players on the Oakland A's (teamID = OAK) in 2007.
3. Who was the AL and NL triple crown winner for 2011 and 2012. If no one won the crown, output "(No winner)"

## Install

1. You'll need Ruby 2.1.2 (see .ruby-version)
2. Run `bundle install` (gemset is named dce)

## Usage

- Run tests with `rspec` or `rake`
- Run the CLI with `rspec go` or `ruby cli.rb`
