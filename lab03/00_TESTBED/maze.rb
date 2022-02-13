# --------------------------------------------------------------------
# An implementation of Aldous-Broder's algorithm for generating mazes.
# This is an easy one to implement, but it is also one of the
# "dumbest" (meaning least intelligent) algorithms. It is not even
# guaranteed to finish, if you get really unlucky with the RNG.
# Watching the animation of its progress can be an exercise in
# frustration as you find yourself urging the cursor to JUST GO
# OVER THERE! Try and it see for yourself. :)
# --------------------------------------------------------------------
# NOTE: the display routine used in this script requires a terminal
# that supports ANSI escape sequences. Windows users, sorry. :(
# --------------------------------------------------------------------

# --------------------------------------------------------------------
# 1. Allow the maze to be customized via command-line parameters
# --------------------------------------------------------------------

width  = (ARGV[0] || 9).to_i
height = (ARGV[1] || width).to_i
seed   = (ARGV[2] || rand(0xFFFF_FFFF)).to_i

srand(seed)

grid = Array.new(height) { Array.new(width, 0) }

# --------------------------------------------------------------------
# 2. Set up constants to aid with describing the passage directions
# --------------------------------------------------------------------

N, S, E, W = 1, 2, 4, 8
DX         = { E => 1, W => -1, N =>  0, S => 0 }
DY         = { E => 0, W =>  0, N => -1, S => 1 }
OPPOSITE   = { E => W, W =>  E, N =>  S, S => N }

# --------------------------------------------------------------------
# 3. A simple routine to emit the maze as ASCII
# --------------------------------------------------------------------

def display_maze(grid, cx=nil, cy=nil)
  # print "\e[H" # move to upper-left
  # puts " " + "_" * (grid[0].length * 2 - 1)
  grid_block = Array.new(18){Array.new(18, 0)}
  a = 1
  grid.each_with_index do |row, y|
    # print "|"
    row.each_with_index do |cell, x|
      if cx == x && cy == y
        print "\e[43m" # cursor is yellow
      elsif cell == 0
        print "\e[47m" # unvisited is white
      end

      # print((cell & S != 0) ? " " : "_")
      if (cell & S != 0)
        # print " "
        a = 1
      elsif y != 8
      # else
        # print "_"
        # print " "
        grid_block[2 * y + 1][2 * x - 1] = 1
        grid_block[2 * y + 1][2 * x] = 1
        grid_block[2 * y + 1][2 * x + 1] = 1
      else
        # print " "
        a = 1
      end
      # print "\e[0m"

      if cell & E != 0
        if (cell | row[x+1]) & S != 0
          # print " "
          a = 1
        elsif y != 8
        # else
          # print "_"
          # print " "
          grid_block[2 * y + 1][2 * x - 1] = 2
          grid_block[2 * y + 1][2 * x] = 2
          grid_block[2 * y + 1][2 * x + 1] = 2
        else
          # print " "
          a = 1
        end
        # print(((cell | row[x+1]) & S != 0) ? " " : "_")
      elsif x != 8
        # print "|"
        # print "0"
        if y != 0
          grid_block[2 * y - 1][2 * x + 1] = 3
        end
        grid_block[2 * y][2 * x + 1] = 3
        grid_block[2 * y + 1][2 * x + 1] = 3
      end
    end
  end
  
  grid_block.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      if x != 17 && y != 17
        if cell != 0
          print "0 "
          # print cell_sec
        else
          print "1 "
        end
      end
    end
    if y != 16
      puts
    end
  end
end

def display_maze_origin(grid, cx=nil, cy=nil)
  # print "\e[H" # move to upper-left
  puts " " + "_" * (grid[0].length * 2 - 1)
  grid.each_with_index do |row, y|
    print "|"
    row.each_with_index do |cell, x|
      if cx == x && cy == y
        print "\e[43m" # cursor is yellow
      elsif cell == 0
        print "\e[47m" # unvisited is white
      end

      print((cell & S != 0) ? " " : "_")
      print "\e[0m"

      if cell & E != 0
        print(((cell | row[x+1]) & S != 0) ? " " : "_")
      else
        print "|"
      end
    end
    puts
  end
end

# --------------------------------------------------------------------
# 4. The Aldous-Broder algorithm
# --------------------------------------------------------------------

# print "\e[2J" # clear screen

x, y = rand(width), rand(height)
remaining = width * height - 1

while remaining > 0
  # display_maze(grid, x, y)
  # sleep 0.02

  [N,S,E,W].shuffle.each do |dir|
    nx, ny = x + DX[dir], y + DY[dir]
    if nx >= 0 && ny >= 0 && nx < width && ny < height
      if grid[ny][nx] == 0
        grid[y][x] |= dir
        grid[ny][nx] |= OPPOSITE[dir]
        remaining -= 1
      end

      x, y = nx, ny
      break
    end
  end
end

display_maze(grid)
# display_maze_origin(grid)

# --------------------------------------------------------------------
# 5. Show the parameters used to build this maze, for repeatability
# --------------------------------------------------------------------
puts
# puts "#{$0} #{width} #{height} #{seed}"
