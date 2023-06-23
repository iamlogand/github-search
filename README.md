# github-search
A script for searching GitHub repos for specific text

### Example usage
Searching for a single word:
```
pr_search.sh vercel next.js this
```

Searching for a string that includes spaces:
```
pr_search.sh vercel next.js "this should only be"
```

### Limitations

- Only searches for comments, review comments and reviews.
- It's very slow, so searching a large repository could take hours or even days.
