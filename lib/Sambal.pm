module Sambal;

class Text {
    has $.text;
    has @.children;
}

class TSpan {
    has $.text;
    has $.font-style = '';
	has $.font-weight = '';
}

grammar Markdown {
    token TOP {
        ^ <paragraph>* % [\n\n+] $
        { make $<paragraph>».ast }
    }

    token paragraph {
        [<!before \n\n> .]+
        {
            my $text = ~$/;
            my @children = TSpan.new(:$text);
            my $saved-match = $/;
            while @children[*-1].text ~~ /'**' <?before \S> (.+?<[*_]>*) <?after \S> '**'/ {
                my $old_tspan = pop @children;
                push @children, TSpan.new(:text($old_tspan.text.substr(0, $/.from)));
                push @children, TSpan.new(:text(~$0), :font-weight('bold'));
                push @children, TSpan.new(:text($old_tspan.text.substr($/.to)));
            }

            while @children[*-1].text ~~ /'*' <?before \S> (.+?<[*_]>*) <?after \S> '*'/ {
                my $old_tspan = pop @children;
                push @children, TSpan.new(:text($old_tspan.text.substr(0, $/.from)));
                push @children, TSpan.new(:text(~$0), :font-style('italics'));
                push @children, TSpan.new(:text($old_tspan.text.substr($/.to)));
            }
			$/ = $saved-match;
            make Text.new(:$text, :@children);
        }
    }
}

class Slide {
    has @.children;

    method new(*@nodes) {
        self.bless(*, :children(@nodes));
    }
}

my @slide_queue;

sub text(Cool $text) is export {
    my @paragraphs = Markdown.parse($text).ast.list;
    push @slide_queue, Slide.new(@paragraphs);
}

our sub slides {
    @slide_queue;
}

our sub _reset {
    @slide_queue = ();
}
