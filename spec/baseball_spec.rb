require 'spec_helper'
require_relative '../baseball'

#
# I'm also using the production data for testing (which is pretty big dataset) but
# I'm not going to use data factories for this simple exercise (or even make smaller)
# test data files.
#
describe Baseball::Player do

  before :all do
    Baseball::Player.fetch!
  end

  # Not used for the solution but was useful for testing along the way
  it "can return all loaded players" do
    all_players = Baseball::Player.all
    expect(all_players.size).to eq(17946)
  end

  it "can return a player by its id" do
    mariano_rivera = Baseball::Player.find 'riverma01'
    expect(mariano_rivera.first_name).to eq('Mariano')
    expect(mariano_rivera.last_name).to eq('Rivera')
    expect(mariano_rivera.birth_year).to eq('1969')
  end

  it "can return a player's batting average" do
    miguel_cabrera = Baseball::Player.find 'cabremi01'
    expect(miguel_cabrera.batting_average(2011)).to be_within(0.001).of(0.344)
  end

  it "can return the percentage of improvement in batting average from year to year" do
    miguel_cabrera = Baseball::Player.find 'cabremi01'
    improvement = miguel_cabrera.batting_average_improvement(2011, 2012, 500) # 500 at-bats min

    expect(improvement).to be_within(0.001).of(-4.497)
  end

  it "can return the player with the most improved batting average from year to year" do
    most_improved_2011_2012_200ab = Baseball::Player.most_improved_batting_average(2011, 2012, 200)
    most_improved_2011_2012_500ab = Baseball::Player.most_improved_batting_average(2011, 2012, 500)

    expect(most_improved_2011_2012_200ab[0]).to eq('colvity01')
    expect(most_improved_2011_2012_200ab[1]).to be_within(0.001).of(48.193)

    expect(most_improved_2011_2012_500ab[0]).to eq('riosal01')
    expect(most_improved_2011_2012_500ab[1]).to be_within(0.001).of(25.299)
  end

  it "can return a team's slugging performance per player for a given year" do
    cin_2007 = Baseball::Player.slugging_performance('CIN', 2007)

    expect(cin_2007).to have(40).items
    expect(cin_2007["arroybr01"]).to be_within(0.001).of(0.214)
    expect(cin_2007["bellhma01"]).to be_within(0.001).of(0.071)
    expect(cin_2007["castrju01"]).to be_within(0.001).of(0.235)
  end

  it "can triple crown winners for a given league by year" do
    winner_al_2011 = Baseball::Player.triple_crown_winner('AL', 2011)
    winner_al_2012 = Baseball::Player.triple_crown_winner('AL', 2012)
    winner_nl_2011 = Baseball::Player.triple_crown_winner('NL', 2011)
    winner_nl_2012 = Baseball::Player.triple_crown_winner('NL', 2011)

    expect(winner_al_2011).to be_nil
    expect(winner_al_2012).to eq('cabremi01')
    expect(winner_nl_2011).to be_nil
    expect(winner_nl_2012).to be_nil
  end

end
