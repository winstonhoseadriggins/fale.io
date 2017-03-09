# fale.io website

This is the source of Fale's personal blog.

## License
The content of this repository is published under the [CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) terms.

## Develop

### Highlight.js
To extract the needed languages for hightlight.js, run:

```
grep -r '```\|~~~' content | awk -F':' '{print $2}' | cut -c 4- | grep -v '^$' | grep -v 'none' | sort | uniq
```
