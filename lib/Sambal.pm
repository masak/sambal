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

sub _DoItalicsAndBold($text is copy) {
    # <strong> must go first:
    $text ~~ s:g[ ('**'||'__') <?before \S> (.+?<[*_]>*) <?after \S> $0 ]
        = "<strong>{$1}</strong>";

    $text ~~ s:g[ ('*'||'_') <?before \S> (.+?) <?after \S> $0 ]
        = "<em>{$1}</em>";

    return $text;
}

sub extract_tspans($text) {
    # XXX the below regex wouldn't work for e.g. <b><em><b>foo</b></em></b>
    gather for $text.split(/'<'(\w+)'>'.*?'</'$0'>'/, :all) -> $normal, $taggy? {
        take TSpan.new(:text($normal));
        if $taggy {
            # XXX highly specialized but works for our immediate purposes
            $taggy.Str ~~ /^ ['<'(\w+)'>']+ (.*?) ['</'\w+'>']+ $/;
            my @tags = $0».Str;
            my $contents = $1;
            my %attrs;
            if any(@tags) eq 'em' { %attrs<font-style> = 'italics' }
            if any(@tags) eq 'strong' { %attrs<font-weight> = 'bold' }
            take TSpan.new(:text($contents), |%attrs);
        }
    }
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
            $text = _DoItalicsAndBold($text);

            my @children = extract_tspans($text);

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
