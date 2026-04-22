# OpenSpec Upstream Sync Script (Windows)
# This script syncs your fork with the upstream OpenSpec repository
# and merges changes into the wiki-integration branch.

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenSpec Upstream Sync" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Save current branch
$CURRENT_BRANCH = git branch --show-current
Write-Host "Current branch: $CURRENT_BRANCH" -ForegroundColor Gray
Write-Host ""

try {
    # Step 1: Switch to main and sync
    Write-Host "[1/6] Switching to main branch..." -ForegroundColor Yellow
    git checkout main
    
    Write-Host "[2/6] Fetching upstream changes..." -ForegroundColor Yellow
    git fetch upstream
    
    Write-Host "[3/6] Merging upstream/main into local main..." -ForegroundColor Yellow
    $mergeResult = git merge upstream/main --no-edit 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Merged successfully" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Merge had conflicts or issues" -ForegroundColor Yellow
    }
    
    Write-Host "[4/6] Pushing updated main to origin..." -ForegroundColor Yellow
    git push origin main
    Write-Host "  ✓ Main branch synced" -ForegroundColor Green
    Write-Host ""
    
    # Step 2: Switch to wiki branch and merge
    Write-Host "[5/6] Merging main into wiki-integration/main..." -ForegroundColor Yellow
    git checkout wiki-integration/main
    
    $mergeResult = git merge main --no-edit 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Merged successfully" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "⚠️  WARNING: Merge conflicts detected!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please resolve conflicts manually:" -ForegroundColor Yellow
        Write-Host "  1. Edit conflicted files" -ForegroundColor Gray
        Write-Host "  2. Run: git add ." -ForegroundColor Gray
        Write-Host "  3. Run: git commit -m 'Resolve merge conflicts'" -ForegroundColor Gray
        Write-Host "  4. Run: git push origin wiki-integration/main" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Conflicted files:" -ForegroundColor Yellow
        git diff --name-only --diff-filter=U
        Write-Host ""
        
        # Don't exit, let user resolve
        $response = Read-Host "Continue with rebuild? (y/n)"
        if ($response -ne "y") {
            Write-Host "Sync paused. Resolve conflicts first." -ForegroundColor Yellow
            exit 0
        }
    }
    
    # Step 3: Push wiki branch
    Write-Host "[6/6] Pushing wiki-integration/main to origin..." -ForegroundColor Yellow
    git push origin wiki-integration/main
    Write-Host "  ✓ Wiki branch synced" -ForegroundColor Green
    Write-Host ""
    
    # Step 4: Rebuild
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Rebuilding..." -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
    
    Write-Host "Building..." -ForegroundColor Yellow
    npm run build
    
    Write-Host "Running tests..." -ForegroundColor Yellow
    npm test
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✅ Sync Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your wiki-integration/main branch is now up to date with upstream." -ForegroundColor Green
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  ❌ Sync Failed" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  - Check your internet connection" -ForegroundColor Gray
    Write-Host "  - Ensure upstream remote is configured:" -ForegroundColor Gray
    Write-Host "    git remote -v" -ForegroundColor Gray
    Write-Host "  - If conflicts exist, resolve them manually" -ForegroundColor Gray
    Write-Host ""
    
    # Try to restore original branch
    try {
        git checkout $CURRENT_BRANCH 2>$null
    } catch {
        # Ignore checkout errors
    }
    
    exit 1
}
finally {
    # Switch back to original branch
    if ($CURRENT_BRANCH -and $CURRENT_BRANCH -ne "wiki-integration/main") {
        Write-Host "Switching back to original branch: $CURRENT_BRANCH" -ForegroundColor Gray
        git checkout $CURRENT_BRANCH 2>$null
    }
}

Write-Host "Done!" -ForegroundColor Green
Write-Host ""
