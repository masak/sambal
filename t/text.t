use v6;
use Test;
use Sambal;

{
    text "One slide";

    my @slides = Sambal::slides();
    is +@slides, 1, "Create one text slide";
    isa_ok @slides[0], Sambal::Slide;
    is +@slides[0].children, 1, "The slide has one element";
    Sambal::_reset();
}

{
    text "One slide.\n\nTwo paragraphs.";

    my @slides = Sambal::slides();
    is +@slides, 1, "Create one text slide";
    is +@slides[0].children, 2, "The slide has two elements";
    Sambal::_reset();
}

done;
