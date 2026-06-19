# NutsNews iOS Category Filter Fix

This update fixes the category filter to match the live NutsNews web app data model.

The web app/API uses a singular `category` string on each article row, such as:

```text
Achievement | Uplifting | Community | Lifestyle
```

The iOS app now decodes that `category` field, splits it with the same separators used by the web app (`|`, `,`, `;`, `/`), and builds the filter chips from the exact labels loaded from articles.

The filter now uses the same API parameter as the web app:

```text
/api/articles?page=0&category=Science
```

`All` shows all articles. Selecting a category asks the NutsNews API for articles that match that exact category label.
