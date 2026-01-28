#!/bin/bash
set -e

echo "============================================="
echo "   SWE-bench Solution Submission"
echo "   Instance: django__django-15814"
echo "============================================="
echo ""

# Check if there are any changes to commit
if git diff-index --quiet HEAD --; then
    echo "ℹ️  No changes detected in working directory."
    echo "   All changes are already committed."
    echo ""
else
    echo "📝 Adding all changes..."
    git add -A
    
    # Prompt for commit message
    echo ""
    echo "Enter commit message (or press Enter for default):" 
    read -r COMMIT_MSG
    
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Solution attempt for django__django-15814"
    fi
    
    echo ""
    echo "💾 Committing changes..."
    git commit -m "$COMMIT_MSG"
fi

echo "📤 Pushing to remote repository (branch: django__django-15814-k796tb)..."
git push origin django__django-15814-k796tb

echo ""
echo "✅ Code pushed successfully!"
echo ""

# Get the current commit hash
COMMIT_HASH=$(git rev-parse HEAD)
REPO_URL=$(git remote get-url origin 2>/dev/null || git remote get-url test-repo 2>/dev/null || echo "unknown")

echo "📊 Submitting to evaluation server..."
echo ""

# Submit to server endpoint
# Replace SUBMISSION_SERVER_URL with your actual server URL
SUBMISSION_SERVER_URL="${SUBMISSION_SERVER_URL:-https://ai-code-gym.cis240515.projects.jetstream-cloud.org:5000}"

RESPONSE=$(curl -s -X POST "$SUBMISSION_SERVER_URL/submit" \
  -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg instance_id "django__django-15814" \
    --arg branch "django__django-15814-k796tb" \
    --arg commit "$COMMIT_HASH" \
    --arg repo "$REPO_URL" \
    '{instance_id: $instance_id, branch: $branch, commit_hash: $commit, repo_url: $repo}')"
  2>&1) || {
  echo "⚠️  Failed to connect to submission server."
  echo "   You can still view your results in the GitHub Actions tab."
  echo ""
  echo "   Repository: $REPO_URL"
  echo "   Branch: django__django-15814-k796tb"
  echo "   Commit: $COMMIT_HASH"
  exit 0
}

echo "Server response:"
echo "$RESPONSE"
echo ""

# Parse submission URL from response (assuming JSON response with 'url' field)
SUBMISSION_URL=$(echo "$RESPONSE" | jq -r '.url // .submission_url // empty' 2>/dev/null || echo "")

if [ -n "$SUBMISSION_URL" ]; then
    echo "============================================="
    echo "✅ Submission successful!"
    echo "============================================="
    echo ""
    echo "📋 View your submission at:"
    echo "   $SUBMISSION_URL"
    echo ""
    echo "You can also check the test results in GitHub Actions:"
    echo "   $REPO_URL/actions"
else
    echo "============================================="
    echo "✅ Code submitted!"
    echo "============================================="
    echo ""
    echo "📋 Check test results in GitHub Actions:"
    echo "   $REPO_URL/actions"
    echo ""
    echo "   Branch: django__django-15814-k796tb"
    echo "   Commit: $COMMIT_HASH"
fi

echo ""
echo "💡 Tip: You can run ./submit.sh again after making more changes."
echo ""
