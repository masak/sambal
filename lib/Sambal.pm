module Sambal;

use Text::Markdown;

class Slide {
    has @.children;

    method new(*@nodes) {
        self.bless(*, :children(@nodes));
    }
}

my @slide_queue;

sub text(Cool $text) is export {
    my $doc = parse-markdown($text);
    my @paragraphs = $doc.children;
    push @slide_queue, Slide.new(@paragraphs);
}

our sub slides {
    @slide_queue;
}

our sub _reset {
    @slide_queue = ();
}
