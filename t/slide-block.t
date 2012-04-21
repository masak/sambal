use v6;
use Test;
use Sambal;

$Sambal::PDF_GEN = False;

{
    text "Slide 1";
    slide {
        text "Slide 2";
        text "Several text objects";
        text "Three, actually";
    }

    my @slides = Sambal::slides();
    is +@slides, 2, "Two slides";
    isa_ok @slides[1], Sambal::Slide;
    is +@slides[1].children, 3, "The slide has three elements";
    Sambal::_reset();
}

done;
