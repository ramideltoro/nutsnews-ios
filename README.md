# NutsNews iOS

Native SwiftUI iOS app for NutsNews.

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
      Features/Feed/
```

## API

The app reads articles from:

```text
https://www.nutsnews.com/api/articles
```

The app supports both camelCase and snake_case article fields, including `thumbnailUrl`, `thumbnail_url`, `imageUrl`, and `image_url`.

No Supabase service keys, OpenAI keys, Cloudflare secrets, or Apple signing secrets belong in this repo.
