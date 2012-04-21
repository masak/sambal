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

constant SVG_HEADER = q[<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg"
   xmlns:xlink="http://www.w3.org/1999/xlink"
   width="800"
   height="600"
   version="1.1">
];

constant SVG_FOOTER = "</svg>\n";

module Serializer {
    our $GEN_DIR = '.sambal-gen';

    our sub write_svg_file($name, Slide $slide) {
        my $fh = open "$GEN_DIR/$name", :w;
        $fh.print(svg($slide));
        $fh.close;
    }

    multi svg(Any $o) { die "Internal error: got a $o.^name()" }

    multi svg(Slide $slide) {
        SVG_HEADER,
        (map { svg($_) }, $slide.children),
        SVG_FOOTER;
    }

    multi svg(Text::Markdown::Para $para) {
        q[<text xml:space="preserve" x="0" y="0">],
        (map { svg($_) }, $para.children),
        qq[</text>\n];
    }

    multi svg(Text::Markdown::TSpan $_) {
        my $style = join '; ',
            (qq[font-style: {.font-style}]   if .font-style),
            (qq[font-weight: {.font-weight}] if .font-weight),
            (qq[font-family: {.font-family}] if .font-family);
        return
            q[<tspan],
            (qq[ style="$style"] if $style),
            q[>],
            .text,
            qq[</tspan>\n];
    }
}

our $PROCESS = True;

END {
    if $PROCESS {
        try {
            mkdir $Serializer::GEN_DIR;
            CATCH {
                when X::IO::Mkdir && .os-error ~~ /:i 'file exists'/ {
                    # ignore this, we want the directory there
                }
            }
        }
        do for @slide_queue.kv -> $num, $slide {
            Serializer::write_svg_file("slide{$num.fmt('%04d')}.svg", $slide);
        } or say "No slides to process. Done.";
    }
}
