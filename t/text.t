use v6;
use Test;
use Sambal;

$Sambal::PDF_GEN = False;

{
    text "One slide";

    my @slides = Sambal::slides();
    is +@slides, 1, "Create one text slide";
    isa-ok @slides[0], Sambal::Slide;
    is +@slides[0].children, 1, "The slide has one element";
    ok (@slides[0].children)[0].items[0] eq "One slide", "It is the right text.";
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
    isa-ok $text, Text::Markdown::Paragraph;
    is +$text.items, 3, "The text has three elements";
    is $text.items[0], "One slide with ", 'correct 1/3 tspan';
    is $text.items[1].text, "italics", 'correct 2/3 tspan';
    is $text.items[2], " in it.", 'correct 3/3 tspan';
    # new Text::Markdown doesn't support font-styles
    # is $text.items[0].font-style, "", 'correct 1/3 font-style';
    # is $text.items[1].font-style, "italic", 'correct 2/3 font-style';
    # is $text.items[2].font-style, "", 'correct 3/3 font-style';
    Sambal::_reset();
}

{
    text "One slide with **bold** in it.";

    my @slides = Sambal::slides();
    is +@slides, 1, "Create one text slide";
    is +@slides[0].children, 1, "The slide has one child";
    my $text = @slides[0].children[0];
    isa-ok $text, Text::Markdown::Paragraph;
    is +$text.items, 3, "The text has three elements";
    is $text.items[0], "One slide with ", 'correct 1/3 tspan';
    is $text.items[1].text, "bold", 'correct 2/3 tspan';
    is $text.items[2], " in it.", 'correct 3/3 tspan';
    # new Text::Markdown doesn't support font-weights
    # is $text.children[0].font-weight, "", 'correct 1/3 font-weight';
    # is $text.children[1].font-weight, "bold", 'correct 2/3 font-weight';
    # is $text.children[2].font-weight, "", 'correct 3/3 font-weight';
    Sambal::_reset();
}

{
    text "Both *beer* and **cheesecake**!?";

    my @slides = Sambal::slides();
    my $text = @slides[0].children[0];
    is +$text.items, 5, "handles italic and bold combined";
    Sambal::_reset();
}

{
    text "Now we use both *italics* and **bold** ***and*** combine them.";

    my @slides = Sambal::slides();
    is +@slides, 1, "Create one text slide";
    is +@slides[0].children, 1, "The slide has one child";
    my $text = @slides[0].children[0];
    isa-ok $text, Text::Markdown::Paragraph;
    is +$text.items, 7, "The text has seven elements";
    is $text.items[0], "Now we use both ", 'correct 1/7 tspan';
    is $text.items[1].text, "italics", 'correct 2/7 tspan';
    is $text.items[2], " and ", 'correct 3/7 tspan';
    is $text.items[3].text, "bold", 'correct 4/7 tspan';
    is $text.items[4], " ", 'correct 5/7 tspan';
    # TODO: fix
    # is $text.items[5].text, "and", 'correct 6/7 tspan';
    is $text.items[6], " combine them.", 'correct 7/7 tspan';
    # new Text::Markdown doesn't support this
    # is $text.children[0].font-style, "", 'correct 1/7 font-style';
    # is $text.children[1].font-style, "italic", 'correct 2/7 font-style';
    # is $text.children[2].font-style, "", 'correct 3/7 font-style';
    # is $text.children[3].font-style, "", 'correct 4/7 font-style';
    # is $text.children[4].font-style, "", 'correct 5/7 font-style';
    # is $text.children[5].font-style, "italic", 'correct 6/7 font-style';
    # is $text.children[6].font-style, "", 'correct 7/7 font-style';
    # is $text.children[0].font-weight, "", 'correct 1/7 font-weight';
    # is $text.children[1].font-weight, "", 'correct 2/7 font-weight';
    # is $text.children[2].font-weight, "", 'correct 3/7 font-weight';
    # is $text.children[3].font-weight, "bold", 'correct 4/7 font-weight';
    # is $text.children[4].font-weight, "", 'correct 5/7 font-weight';
    # is $text.children[5].font-weight, "bold", 'correct 6/7 font-weight';
    # is $text.children[6].font-weight, "", 'correct 7/7 font-weight';
    Sambal::_reset();
}

{
    text "This text contains `code` written in Perl 6.";
    my @slides = Sambal::slides();
    is +@slides, 1, "Create one text slide";
    is +@slides[0].children, 1, "The slide has one child";
    my $text = @slides[0].children[0];
    isa-ok $text, Text::Markdown::Paragraph;
    is +$text.items, 3, "The text has 3 elements.";
    is $text.items[0], "This text contains ", 'correct 1/3 tspan';
    is $text.items[1].text, "code", 'correct 2/3 tspan';
    is $text.items[2], " written in Perl 6.", 'correct 3/3 tspan';
    # new Text::Markdown doesn't support this
    # is $text.items[0].font-family, '', 'correct 1/3 font-family';
    # is $text.items[1].font-family, 'monospace', 'correct 2/3 font-family';
    # is $text.items[2].font-family, '', 'correct 3/3 font-family';
    Sambal::_reset();
}

done-testing;
