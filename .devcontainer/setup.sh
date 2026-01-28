#!/bin/bash
# Don't exit on error - continue even if some installations fail
set +e

echo "Setting up SWE-bench environment..."
echo "Working directory: $(pwd)"
echo "Current commit: $(git rev-parse HEAD)"

# Save current state
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

# If environment_setup_commit is specified and different, checkout for installation
ENV_SETUP_COMMIT="0fbdb9784da915fce5dcc1fe82bac9b4785749e5"
BASE_COMMIT="5eb6a2b33d70b9889e1cafa12594ad6f80773d3a"

if [ -n "$ENV_SETUP_COMMIT" ] && [ "$ENV_SETUP_COMMIT" != "$BASE_COMMIT" ]; then
  echo "Checking out environment setup commit for proper dependency installation..."
  git fetch origin
  git checkout $ENV_SETUP_COMMIT 2>&1 || echo "Warning: Could not checkout environment setup commit"
fi

# Wait for filesystem to be ready
sleep 2

# Upgrade pip
echo "Upgrading pip..."
python -m pip install --upgrade pip 2>&1 || echo "Warning: pip upgrade had issues"

# Install pytest
echo "Installing pytest..."
pip install pytest 2>&1 || echo "Warning: pytest installation had issues"

# Install package dependencies (at environment_setup_commit if specified)
if [ -f "setup.py" ]; then
  echo "Found setup.py - Installing package in editable mode..."
  pip install -e . 2>&1 || echo "Warning: Failed to install with setup.py (this may be expected)"
elif [ -f "pyproject.toml" ]; then
  echo "Found pyproject.toml - Installing package..."
  pip install -e . 2>&1 || echo "Warning: Failed to install with pyproject.toml (this may be expected)"
else
  echo "No setup.py or pyproject.toml found - skipping package installation"
fi

# Install requirements files if they exist
for req_file in requirements.txt requirements-dev.txt test-requirements.txt; do
  if [ -f "$req_file" ]; then
    echo "Installing $req_file..."
    pip install -r "$req_file" 2>&1 || echo "Warning: Some packages in $req_file failed (continuing anyway)"
  fi
done

# Return to base commit if we checked out environment_setup_commit
if [ -n "$ENV_SETUP_COMMIT" ] && [ "$ENV_SETUP_COMMIT" != "$BASE_COMMIT" ]; then
  echo "Returning to base commit..."
  git checkout $BASE_COMMIT 2>&1 || git checkout $CURRENT_BRANCH 2>&1 || echo "Warning: Could not return to original state"
fi

echo ""
echo "✅ Environment setup complete!"
echo "Final commit: $(git rev-parse HEAD)"
echo ""
echo "📋 Next steps:"
echo "  1. Read problem_statement.md to understand the issue"
echo "  2. Check hints_text.md for additional context"
echo "  3. Make changes to fix the issue"
echo "  4. Commit and push to trigger automated tests"
echo ""
