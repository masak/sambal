Sambal is a small presentation frame work with high ideals.

## Usage

    use Sambal;

    text 'Example presentation title slide';
    
    text 'Markdown *italics*, **bold**, and `code` all work';
    
    text 'Have a spicy day!';

## Roadmaps

Short term (Oslo hackathon) roadmap:

* A bit more of Markdown working
    * inline code
    * block-level code
* source → SVG → PDF
    * serializing to SVG
    * calling Inkscape to generate PDFs
    * calling, um, `pdfjoin` to generate one PDF
    * fall back gracefully when Inkscape, `pdfjoin` are missing
* Develop two nice skins
    * one called "sushi" which is mostly black/white/green
    * one called "chocolate mint" which is brown/light green

Long term roadmap:

* Fix the problem with [https://gist.github.com/2173720](text positioning) once and for all
* `transition`
* Layouts
* Gradual slide buildup
    * Maybe using `<!>` markers in the text
    * But we also need a non-text variant of this for Niobium
    * Some slides do buildup, and others are "outside of the flow"
* [font awesome](http://fortawesome.github.com/Font-Awesome/) integration
* The whole [Niobium](https://gist.github.com/1751911) integration

There are some interesting design decisions waiting in the area around layouts
and Niobium integration. Basically, code examples trump abstract discussions,
and working implementation trumps everything else. ☺
