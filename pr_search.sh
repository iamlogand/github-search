#!/bin/bash

# The first three command line arguments
owner=$1
repo=$2
search_text=$3

# Your GitHub token, replace "YOUR_GITHUB_TOKEN" with your actual token
token="YOUR_GITHUB_TOKEN"

page=1
while true; do
    # Use GitHub API to get a page of PRs (both open and closed)
    response=$(curl -s -H "Authorization: token $token" -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$owner/$repo/pulls?state=all&per_page=100&page=$page")
    
    prs=$(echo "$response" | jq -r '.[].number')

    # If no PRs were returned, we're done
    if [[ -z "$prs" ]]; then
        break
    fi

    for pr in $prs; do

        echo "Processing PR #$pr"

        comment_page=1
        while true; do
            # Use GitHub API to get a page of comments of each PR
            response=$(curl -s -H "Authorization: token $token" -H "Accept: application/vnd.github.v3+json" \
                "https://api.github.com/repos/$owner/$repo/issues/$pr/comments?page=$comment_page")

            comments=$(echo "$response" | jq -rc '.[] | .body')

            # If no comments were returned, break the loop
            if [[ -z "$comments" ]]; then
                break
            fi

            IFS=$'\n'       # make newlines the only separator
            for comment in $comments
            do
                # Check if the comment contains the search text
                if [[ $comment == *"$search_text"* ]]; then
                    echo "    Match found in PR #$pr. Comment: $comment"
                    exit 0
                fi
            done
            unset IFS      # restore default separator

            # Increment comment page number
            ((comment_page++))
        done

        review_comment_page=1
        while true; do
            # Use GitHub API to get a page of review comments of each PR
            response=$(curl -s -H "Authorization: token $token" -H "Accept: application/vnd.github.v3+json" \
                "https://api.github.com/repos/$owner/$repo/pulls/$pr/comments?page=$review_comment_page")

            comments=$(echo "$response" | jq -rc '.[] | .body')

            # If no review comments were returned, break the loop
            if [[ -z "$comments" ]]; then
                break
            fi

            IFS=$'\n'       # make newlines the only separator
            for comment in $comments
            do
                # Check if the review comment contains the search text
                if [[ $comment == *"$search_text"* ]]; then
                    echo "    Match found in PR #$pr. Review comment: $comment"
                    exit 0
                fi
            done
            unset IFS      # restore default separator

            # Increment review comment page number
            ((review_comment_page++))
        done

        review_page=1
        while true; do
            # Use GitHub API to get a page of reviews of each PR
            response=$(curl -s -H "Authorization: token $token" -H "Accept: application/vnd.github.v3+json" \
                "https://api.github.com/repos/$owner/$repo/pulls/$pr/reviews?page=$review_page")

            comments=$(echo "$response" | jq -rc '.[] | .body')

            # If no reviews were returned, break the loop
            if [[ -z "$comments" ]]; then
                break
            fi

            IFS=$'\n'       # make newlines the only separator
            for comment in $comments
            do
                # Check if the review contains the search text
                if [[ $comment == *"$search_text"* ]]; then
                    echo "    Match found in PR #$pr. Review: $comment"
                    exit 0
                fi
            done
            unset IFS      # restore default separator

            # Increment review page number
            ((review_page++))
        done
    done

    # Increment PR page number
    ((page++))
done