# Admin Feature

Modern admin dashboard for approving/rejecting startup and investor profiles.

## Overview

The admin feature provides a beautiful, user-friendly interface for administrators to review and manage pending profile applications. When a user with the email `admin@gmail.com` logs in, they are automatically redirected to the admin dashboard.

## Features

- **Dual Tab Interface**: Separate tabs for reviewing startups and investors
- **Statistics Dashboard**: Real-time counts of pending, approved, and rejected profiles
- **Expandable Profile Cards**: 
  - Compact view showing key information
  - Expandable to show full details including description, contact info, and funding details
  - Color-coded by type (startups vs investors)
- **Quick Actions**: Approve or reject with a single tap
- **Pull to Refresh**: Easy data reload
- **Professional Design**: Matches the app's existing design system with Action Cyan primary color

## Architecture

Following clean architecture principles:

```
admin/
├── data/
│   ├── datasources/
│   │   ├── admin_remote_data_source.dart (interface)
│   │   └── admin_remote_data_source_impl.dart (Supabase implementation)
│   ├── models/
│   │   └── pending_approval_model.dart
│   └── repositories/
│       └── admin_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── pending_approval_entity.dart
│   ├── repositories/
│   │   └── admin_repository.dart (interface)
│   └── usecases/
│       ├── get_pending_startups.dart
│       ├── get_pending_investors.dart
│       ├── approve_profile.dart
│       └── reject_profile.dart
└── presentation/
    ├── cubit/
    │   ├── admin_cubit.dart
    │   └── admin_state.dart
    ├── pages/
    │   └── admin_dashboard_page.dart
    └── widgets/
        ├── approval_stats_card.dart
        └── pending_profile_card.dart
```

## Database Schema

The feature requires an `approval_status` column in both `startup_profiles` and `investor_profiles` tables:

```sql
ALTER TABLE startup_profiles 
ADD COLUMN approval_status TEXT DEFAULT 'pending' 
CHECK (approval_status IN ('pending', 'approved', 'rejected'));

ALTER TABLE investor_profiles 
ADD COLUMN approval_status TEXT DEFAULT 'pending' 
CHECK (approval_status IN ('pending', 'approved', 'rejected'));
```

See `database_migrations/add_approval_status.sql` for the complete migration.

## Admin Access

To access the admin dashboard:

1. Login with email: `admin@gmail.com`
2. You'll be automatically redirected to `/admin-dashboard`

The admin email is configured in `AppConstants.adminEmail`.

## Usage

The admin dashboard automatically loads pending profiles on mount. Admins can:

1. **Review Profiles**: Tap any card to expand and see full details
2. **Approve**: Tap the green "Approve" button to grant access
3. **Reject**: Tap the red "Reject" button to deny access
4. **Refresh**: Pull down to reload all profiles

After approval/rejection, the profile is moved to the appropriate list and the user can (or cannot) access the app features based on their status.

## UI Components

### ApprovalStatsCard
Shows count of profiles in each status category (pending, approved, rejected) with color-coded icons.

### PendingProfileCard
Expandable card displaying:
- Business logo/icon
- Business name
- Profile type badge (Startup/Investor)
- Submission date
- Industry, location, funding stage chips
- Expandable section with contact details, funding amount, and description
- Approve/Reject action buttons

## Dependencies

- `flutter_bloc` - State management
- `equatable` - Value equality
- `intl` - Date and number formatting
- `get_it` - Dependency injection

## Future Enhancements

- Search and filter functionality
- Detailed approval history
- Notification system for approved/rejected users
- Bulk actions (approve/reject multiple)
- Admin notes/comments on profiles
- Email notifications to users on status change
