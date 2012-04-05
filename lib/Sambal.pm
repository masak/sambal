module Sambal;

class Text {
}

class Slide {
    has @.children;

    method new(*@nodes) {
        self.bless(*, :children(@nodes));
    }
}

my @slide_queue;

sub text(Cool $text) is export {
    push @slide_queue, Slide.new(Text.new);
}

our sub slides {
    @slide_queue;
}
