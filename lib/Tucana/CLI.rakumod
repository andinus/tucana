unit module Tucana::CLI;

use Octans::Neighbors;

# If no arguments are passed then run USAGE & exit.
proto MAIN (|) is export {unless so @*ARGS {say $*USAGE; exit;}; {*}}

multi sub MAIN (Bool :$version) {
    say "Tucana v" ~ $?DISTRIBUTION.meta<version>;
}

multi sub MAIN (
    Str $word, #= word for the puzzle
    Bool :v($verbose), #= increase verbosity
) {
    my @puzzle := generate-puzzle($word);
    "  $_".say for @puzzle;
}

# generate-puzzle generates a 3x3 puzzle with $word in there.
sub generate-puzzle (
    Str $word,
) {
    my @puzzle := [
        [<_ _ _ _>],
        [<_ _ _ _>],
        [<_ _ _ _>],
        [<_ _ _ _>],
    ];

    my Int ($y, $x) = edges(@puzzle).pick;
    @puzzle[$y][$x] = $word.comb[0];

    my @visited;
    @visited[$y][$x] = True;

    my Int $count = 1;
    while $count < $word.chars {
        neighbor: for neighbors(@puzzle, $y, $x).pick(*) -> ($pos-y, $pos-x) {
            next neighbor if @visited[$pos-y][$pos-x];
            @visited[$pos-y][$pos-x] = True;

            @puzzle[$pos-y][$pos-x] = $word.comb[$count];
            ($y, $x) = ($pos-y, $pos-x);
            last neighbor;
        }

        $count++;
    }

    return @puzzle;
}

# edges takes a 2d grid & returns the list of edges, i.e. squares with
# < 4 neighbors.
sub edges (
    @puzzle --> List
) {
    my List @edges;
    for 0 .. @puzzle.end -> $y {
        for 0 .. @puzzle[$y].end -> $x {
            push @edges, ($y, $x) if neighbors(@puzzle, $y, $x).elems < 4;
        }
    }
    return @edges;
}
