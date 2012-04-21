use v6;
use Test;
use Sambal;

$Sambal::PDF_GEN = False;

{
    text "Slide 1";
    transition;
    text "Slide 2";

    my @slides = Sambal::slides();
    is +@slides, 3, "1 + 1 + 1 slides";
    isa_ok @slides[1], Sambal::Slide::Transition;

    Sambal::_expand_transition_slides();
    @slides = Sambal::slides();
    is +@slides, 11, "1 + 9 + 1 slides";
    isa_ok @slides[1], Sambal::Slide::Transition;
    isa_ok @slides[1].previous, Sambal::Slide;
    isa_ok @slides[1].next, Sambal::Slide;

    Sambal::_reset();
}

done;
