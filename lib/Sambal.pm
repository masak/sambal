module Sambal;

class Text {
    has $.text;
}

class Slide {
    has @.children;

    method new(*@nodes) {
        self.bless(*, :children(@nodes));
    }
}

my @slide_queue;

sub text(Cool $text) is export {
    push @slide_queue, Slide.new(Text.new(:$text));
}

our sub slides {
    @slide_queue;
}

our sub _reset {
    @slide_queue = ();
}
