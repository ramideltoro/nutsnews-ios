# NutsNews iOS

Native SwiftUI iOS app for NutsNews.

## Current MVP

- Native SwiftUI feed
- Pulls articles from the NutsNews public API
- Shows thumbnails, title, summary, source, date, and category badges
- Opens a native article detail screen when tapping a card or the Read Story button
- Opens original publisher stories inside an in-app Safari view
- Supports sharing original story links
- Article detail title uses a smaller font and unlimited wrapping so full headlines remain visible
- Supports pull-to-refresh and infinite loading

## Open locally

```bash
cd /Users/ramideltoro/WebstormProjects/nutsnews-ios
open NutsNews/NutsNews.xcodeproj
```

Choose an iPhone simulator and press `Command + R`.

## Structure

```text
nutsnews-ios/
  NutsNews/
    NutsNews.xcodeproj
    NutsNews/
      ContentView.swift
      NutsNewsApp.swift
      Models/
      Networking/
      Design/
      Support/
      Features/
        Feed/
        Article/
```

## API

The app reads articles from:

```text
https://www.nutsnews.com/api/articles
```

The app supports both camelCase and snake_case article fields, including `thumbnailUrl`, `thumbnail_url`, `imageUrl`, and `image_url`.

No Supabase service keys, OpenAI keys, Cloudflare secrets, or Apple signing secrets belong in this repo.
