Sambal is a small presentation frame work with high ideals.

## Usage

    use Sambal;

    text 'Example presentation title slide';
    
    text 'Markdown *italics*, **bold**, and `code` all work';
    
    text 'Have a spicy day!';

## External dependencies

This module works standalone, but it won't generate a PDF for you until
you have the following external programs installed:

* [Inscape](http://inkscape.org/)
* [pdfjoin](http://freecode.com/projects/pdfjam)

You might be able to find either or both of these through your local
package manager. For example,

    $ sudo apt-get install inkscape pdfjam

will install both on Debian/Ubuntu.

## Roadmaps

We got a bunch of stuff done at the Oslo hackathon. Here are a few low-hanging
fruits that remain:

* A bit more of Markdown working
    * block-level code
* Develop two nice skins
    * one called "sushi" which is mostly black/white/green
    * one called "chocolate mint" which is brown/light green

Long term roadmap:

* Fix the problem with [https://gist.github.com/2173720](text positioning) once and for all
* Layouts
* Gradual slide buildup
    * Maybe using `<!>` markers in the text
    * But we also need a non-text variant of this for Niobium
    * And for objects in general, really
    * Some slides do buildup, and others are "outside of the flow"
    * Could have the concept of `save` and `load` inside a `slide {}`
    * And then `save` and `load` could also take a string name, to
      save and load multiple things
* [font awesome](http://fortawesome.github.com/Font-Awesome/) integration
* The whole [Niobium](https://gist.github.com/1751911) integration
* At some point, the whole notion of "model" vs "view" needs to be
  integrated into the Niobium parts.
* This naturally leads to things like animated slides. Maybe backport
  `transition` to work using such animations?

There are some interesting design decisions waiting in the area around layouts
and Niobium integration. Basically, code examples trump abstract discussions,
and working implementation trumps everything else. ☺
