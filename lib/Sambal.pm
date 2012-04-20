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
    my @paragraphs = map { Text.new(:text($_)) }, $text.split(/\n\n+/);
    push @slide_queue, Slide.new(@paragraphs);
}

our sub slides {
    @slide_queue;
}

our sub _reset {
    @slide_queue = ();
}
