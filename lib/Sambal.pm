module Sambal;

class Slide {
}

my @slide_queue;

sub text(Cool $text) is export {
    push @slide_queue, Slide.new;
}

our sub slides {
    @slide_queue;
}
