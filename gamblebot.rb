class Round
  
  def initialize(players)
    @players = players
    @turn_counter = 0
  end

  def winner
    @winner || self.play!
  end

  def play!
    until @winner do
      if current_player.decision(victim, @last_hit) == :roll
        roll!
      else
        attack!
      end
    end
    @winner
  end

  def roll!
    roll_result = rand(6) + 1
    if roll_result == 1
      current_player.accumulated_damage = 0
      end_turn!
    else
      current_player.accumulated_damage += roll_result
    end
  end

  def end_turn!
    if victim.hit_points <= 0
      @winner = current_player
      # puts "Round Result: #{@winner.class}, #{@winner.hit_points}; #{victim.class}, #{victim.hit_points}"
    else
      @turn_counter += 1
    end
  end

  def attack!
    victim.hit_points -= current_player.accumulated_damage
    @last_hit = current_player.accumulated_damage
    current_player.accumulated_damage = 0
    end_turn!
  end

  def current_player
    @players[@turn_counter % 2]
  end

  def victim
    @players[(@turn_counter + 1 ) % 2]
  end
end

class Player
  attr_accessor :hit_points, :accumulated_damage
  def initialize
    @hit_points = 100
    @accumulated_damage = 0
  end

  def decision(victim, last_hit)
    if accumulated_damage >= victim.hit_points
      # puts "Default attack"
      :attack
    elsif accumulated_damage == 0
      # puts "Default roll"
      :roll
    else
      # puts "#{self.class} Strategy"
      strategy(victim, last_hit)
    end
  end
end

class ZenoPlayer < Player
  def strategy(victim, last_hit)
    if accumulated_damage >= victim.hit_points / 2
      :attack
    else
      :roll
    end
  end
end

class ZenoPlayerB < ZenoPlayer
end

class LuckyNumberPlayer < Player
  def strategy(victim, last_hit)
    if accumulated_damage >= 21
      :attack
    else
      :roll
    end
  end
end

class RandomPlayer < Player
  def strategy(victim, last_hit)
    [:roll, :attack].sample
  end
end

class BrutePlayer < Player
  def strategy(victim, last_hit)
    if accumulated_damage >= 100
      :attack
    else
      :roll
    end
  end
end


ROUNDS = 50000 # Rounds are matched pairs - P1 first, then P2 first

matches = [[RandomPlayer, ZenoPlayer], [RandomPlayer, LuckyNumberPlayer],
          [ZenoPlayer, LuckyNumberPlayer], [BrutePlayer, RandomPlayer],
          [BrutePlayer, LuckyNumberPlayer], [ZenoPlayer, ZenoPlayerB]]


matches.each do |match_pair|
results = Hash.new(0)
  ROUNDS.times do
    results[Round.new(match_pair.map(&:new)).winner.class] += 1
    results[Round.new(match_pair.reverse.map(&:new)).winner.class] += 1
  end
  puts match_pair.join(" VS ")
  results.each do |k, v|
    puts "#{k}: #{(v * 100) / (ROUNDS * 2.to_f)}%"
  end
  puts "\n"
end