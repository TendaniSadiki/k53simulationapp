# Database Seeding Pipeline

## Overview
This GitHub Actions workflow automates the process of seeding your Supabase database with Evolve Academy questions. The pipeline runs the seeding script and provides notifications.

## Workflow Features

### Trigger Events
- **Manual trigger**: Run from GitHub Actions UI
- **Automatic on push**: When scripts change or workflow file updates
- **Main branch only**: Runs only on the main branch

### Steps
1. **Checkout code**: Gets the latest code
2. **Setup Flutter**: Configures Flutter environment
3. **Install dependencies**: Runs `flutter pub get`
4. **List scripts**: Shows available seeding scripts
5. **Run seeding**: Executes the Evolve Academy seeding script
6. **Verification**: Confirms successful completion
7. **Notifications**: Sends Slack notifications (success/failure)

## Setup Requirements

### GitHub Secrets
Set these secrets in your repository settings:

| Secret Name | Description |
|-------------|-------------|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key (bypasses RLS) |

### Slack Notifications (Optional)
To enable Slack notifications, add these secrets:
- `SLACK_WEBHOOK_URL`: Your Slack incoming webhook URL

## Manual Execution

1. Go to your GitHub repository → Actions
2. Select "Database Seeding Pipeline" 
3. Click "Run workflow"
4. Select branch (default: master)
5. Click "Run workflow"

## Automated Execution

The workflow runs automatically when:
- Scripts in `scripts/` directory change
- The workflow file itself is updated
- Pushes to the main branch

## Questions Seeded

The pipeline seeds your database with:
- **66 Rules of the Road questions**
- **14 Vehicle Controls questions** 
- **Total: 80 Evolve Academy questions**

## Customization

### Adding More Scripts
To add additional seeding scripts:

1. Place new scripts in the `scripts/` directory
2. Add additional steps in the workflow:

```yaml
- name: Run Additional Script
  run: dart run scripts/your_script.dart
  env:
    SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
    SUPABASE_SERVICE_ROLE_KEY: ${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}
```

### Environment Variables
Add additional environment variables as needed:

```yaml
env:
  CUSTOM_VAR: ${{ secrets.CUSTOM_SECRET }}
```

### Schedule
Add scheduled runs:

```yaml
on:
  schedule:
    - cron: '0 3 * * *'  # Daily at 3 AM
```

## Troubleshooting

### Common Issues
1. **Missing secrets**: Ensure all required secrets are set
2. **Database permissions**: Service role key must have insert permissions
3. **Network issues**: Check if Supabase URL is accessible from GitHub Actions

### Debugging
Enable step debugging by adding:

```yaml
- name: Debug information
  run: |
    echo "Supabase URL: ${{ secrets.SUPABASE_URL }}"
    echo "Script path: scripts/seed_evolve_academy_final.dart"
```

## Security Notes

- **Service role key**: This has elevated permissions - keep it secure
- **Database access**: Ensure proper RLS policies are in place
- **Secret rotation**: Regularly rotate your Supabase service role key