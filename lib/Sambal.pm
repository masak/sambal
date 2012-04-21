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
our $GEN_DIR = '.sambal-gen';

module Serializer {
    our sub write_svg_file($name, Slide $slide) {
        my $fh = open "$GEN_DIR/$name", :w;
        $fh.print(svg($slide));
        $fh.close;
    }

    multi svg(Any $o) { die "Internal error: got a $o.^name()" }

    multi svg(Slide $slide) {
        my $*num_paras = +$slide.children;
        my $*para_index = 0;
        # The 'eager' is needed in order to evaluate the `map` in
        # the dynamic scope of the above variables.
        eager
            SVG_HEADER,
            (map { svg($_) }, $slide.children),
            SVG_FOOTER;
    }

    multi svg(Text::Markdown::Para $para) {
        my $y = 300 - 50 * ($*num_paras - 1) + 100 * $*para_index++;
        my $style = 'font-size:40px;text-anchor:middle';
        qq[<text xml:space="preserve" x="400" y="$y" style="$style">],
        (map { svg($_) }, $para.children),
        qq[</text>\n];
    }

    multi svg(Text::Markdown::TSpan $_) {
        my $style = join '; ',
            (qq[font-style: {.font-style}]   if .font-style),
            (qq[font-weight: {.font-weight}] if .font-weight),
            (qq[font-family: Andale Mono]    if .font-family eq 'monospace');
        return
            q[<tspan],
            (qq[ style="$style"] if $style),
            q[>],
            .text,
            qq[</tspan>];
    }
}

our $PDF_GEN = True;
my $inkscape_executable;
my $pdfjoin_executable;

sub sambal_to_svgs {
    shell "rm -rf $GEN_DIR";
    mkdir $GEN_DIR;
    do for @slide_queue.kv -> $num, $slide {
        Serializer::write_svg_file("slide{$num.fmt('%04d')}.svg", $slide);
    } or die "No slides to process. Done.";
}

sub svgs_to_pdfs {
    for @slide_queue.kv -> $num, $slide {
        my $arguments = join ' ',
            '--without-gui',
            "--file=$GEN_DIR/slide{$num.fmt('%04d')}.svg",
            "--export-pdf=$GEN_DIR/slide{$num.fmt('%04d')}.pdf",
            '2> /dev/null';     # not really an argument, but works :)
        shell "$inkscape_executable $arguments";
    }
}

sub pdfs_to_final_pdf {
    shell "pdfjoin -q -o talk.pdf $GEN_DIR/*.pdf";
}

sub generate_final_pdf {
    $inkscape_executable = qx[which inkscape].chomp;
    $pdfjoin_executable  = qx[which pdfjoin].chomp;
    die "`inkscape` not found in path"
        unless $inkscape_executable;
    die "`pdfjoin` not found in path"
        unless $inkscape_executable;
    sambal_to_svgs();
    svgs_to_pdfs();
    pdfs_to_final_pdf();
}

END {
    if $PDF_GEN {
        generate_final_pdf();
    }
}
