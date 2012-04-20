use v6;
use Test;
use Sambal;

{
    text "One slide";

    my @slides = Sambal::slides();
    is +@slides, 1, "Create one text slide";
    isa_ok @slides[0], Sambal::Slide;
    is +@slides[0].children, 1, "The slide has one element";
    ok (@slides[0].children)[0].text eq "One slide", "It is the right text.";
    Sambal::_reset();
}

{
    text "One slide.\n\nTwo paragraphs.";

    my @slides = Sambal::slides();
    is +@slides, 1, "Create one text slide";
    is +@slides[0].children, 2, "The slide has two elements";
    Sambal::_reset();
}

{
    text "One slide with *italics* in it.";

    my @slides = Sambal::slides();
    is +@slides, 1, "Create one text slide";
    is +@slides[0].children, 1, "The slide has one child";
    my $text = @slides[0].children[0];
    isa_ok $text, Sambal::Text;
    is +$text.children, 3, "The text has three elements";
    is $text.children[0].text, "One slide with ";
    is $text.children[1].text, "italics";
    is $text.children[2].text, " in it.";
    is $text.children[0].font-style, "";
    is $text.children[1].font-style, "italics";
    is $text.children[2].font-style, "";
    Sambal::_reset();
}

done;
