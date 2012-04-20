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
            sub bold_match($text) {
                my @tspans = TSpan.new(:$text);
                while @tspans[*-1].text ~~ /'**' <?before \S> (.+?<[*_]>*) <?after \S> '**'/ {
                    my $old_tspan = pop @tspans;
                    push @tspans, italics_match($old_tspan.text.substr(0, $/.from));
                    push @tspans, TSpan.new(:text(~$0), :font-weight('bold'));
                    push @tspans, TSpan.new(:text($old_tspan.text.substr($/.to)));
                }
                my $last_tspan = pop @tspans;
                push @tspans, italics_match($last_tspan.text);
                return @tspans;
            }

            sub italics_match($text) {
                my @tspans = TSpan.new(:$text);
                while @tspans[*-1].text ~~ /'*' <?before \S> (.+?) <?after \S> '*'/ {
                    my $old_tspan = pop @tspans;
                    push @tspans, TSpan.new(:text($old_tspan.text.substr(0, $/.from)));
                    push @tspans, TSpan.new(:text(~$0), :font-style('italics'));
                    push @tspans, TSpan.new(:text($old_tspan.text.substr($/.to)));
                }
                return @tspans;
            }

            my $text = ~$/;

            my @children = bold_match($text);

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
