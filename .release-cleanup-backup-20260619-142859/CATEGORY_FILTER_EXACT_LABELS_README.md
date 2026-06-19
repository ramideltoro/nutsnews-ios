# NutsNews iOS Exact Category Label Filter Update

This update makes the iOS category filter use the same category labels that appear on the NutsNews web article cards.

Behavior:

- `All` shows every loaded article card
- Category chips are generated from `article.categories`
- Category chip order follows the loaded article cards and category order
- Tapping a category shows only cards whose `article.categories` contain that exact category label, case-insensitive
- No fuzzy keyword grouping is used

This matches the web app behavior: the filter labels come directly from the card category labels.
