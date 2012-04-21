module Sambal;

use Text::Markdown;

class Slide {
    has @.children;
}

class Slide::Transition is Slide {
    has $.previous;
    has $.next;
    has $.progress;
}

my @slide_queue;

sub text(Cool $text) is export {
    my $doc = parse-markdown($text);
    my @children = $doc.children;
    push @slide_queue, Slide.new(:@children);
}

sub slide(&block) is export {
    my $prior_length = +@slide_queue;
    die "Can't pass a block that requires parameters to &slide"
        unless &block.arity == 0;
    &block();
    my @children;
    for @slide_queue[$prior_length .. *-1] -> $slide {
        die "Can't have transitions inside slide"
            if $slide ~~ Slide::Transition;
        push @children, $slide.children[];
    }
    @slide_queue = @slide_queue[^$prior_length], Slide.new(:@children);
}

sub transition is export {
    push @slide_queue, Slide::Transition.new();
}

our sub slides {
    @slide_queue;
}

our sub _reset {
    @slide_queue = ();
}

our $TRANSITION_STEPS = 9;

our sub _expand_transition_slides {
    my @new_queue;
    for @slide_queue.kv -> $i, $_ {
        when Slide::Transition {
            my $previous = @slide_queue[$i - 1];
            my $next     = @slide_queue[$i + 1];
            for ^$TRANSITION_STEPS {
                sub smooth($x) { (1 - cos(pi * $x))/2 }
                my $progress = ($_ + 1) / ($TRANSITION_STEPS + 1);
                $progress = smooth(smooth($progress));
                push @new_queue,
                     Slide::Transition.new(:$previous, :$next, :$progress);
            }
        }
        default { push @new_queue, $_ }
    }
    @slide_queue := @new_queue;
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
        SVG_HEADER,
        slide_svg($slide),
        SVG_FOOTER;
    }

    sub slide_svg(Slide $slide) {
        my $*num_paras = +$slide.children;
        my $*para_index = 0;
        # The 'eager' is needed in order to evaluate the `map` in
        # the dynamic scope of the above variables.
        eager map { svg($_) }, $slide.children;
    }

    multi svg(Slide::Transition $trans) {
        my $prev_offset = -800 * $trans.progress;
        my $next_offset = 800 * (1 - $trans.progress);
        SVG_HEADER,
        qq[<g transform="translate($prev_offset, 0)">], slide_svg($trans.previous), '</g>',
        qq[<g transform="translate($next_offset, 0)">], slide_svg($trans.next), '</g>',
        SVG_FOOTER
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
    _expand_transition_slides();
    if $PDF_GEN {
        generate_final_pdf();
    }
}
