# NutsNews iOS Category Filter Update

This update removes the default navigation title and the descriptive header copy from the main feed.

The top of the feed now shows:

- Centered amber `NutsNews` title
- A single horizontal, scrollable row of category tags
- Category chips that filter the visible articles in the feed
- An `All` chip to reset the feed

The filter is local to the articles already loaded from `https://www.nutsnews.com/api/articles`. If a selected category has no visible stories yet, the app shows a `Load more stories` button when more pages are available.
