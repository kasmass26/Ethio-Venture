# Admin Feature Setup Guide

This guide will help you set up the admin approval feature for your EthioVenture app.

## Prerequisites

- Flutter development environment set up
- Supabase project configured
- Access to your Supabase database

## Step 1: Install Dependencies

Run the following command to install new packages:

```bash
flutter pub get
```

This will install:
- `equatable` - For value equality in state management
- `intl` - For date and number formatting

## Step 2: Database Migration

You need to add the `approval_status` column to your database tables.

### Option A: Using Supabase Dashboard (Recommended)

1. Go to your Supabase dashboard
2. Navigate to the SQL Editor
3. Copy and paste the contents of `database_migrations/add_approval_status.sql`
4. Run the migration

### Option B: Using Supabase CLI

```bash
supabase migration new add_approval_status
# Copy the SQL from database_migrations/add_approval_status.sql to the generated file
supabase db push
```

### What the migration does:

- Adds `approval_status` column to `startup_profiles` table (values: pending, approved, rejected)
- Adds `approval_status` column to `investor_profiles` table (values: pending, approved, rejected)
- Creates indexes for faster queries
- Sets existing profiles to 'approved' status (so they continue working)
- Adds `approval_date` timestamp column for tracking when approval/rejection happened

## Step 3: Update Row Level Security (RLS) Policies

Make sure your RLS policies allow the admin to read all profiles. Add these policies in Supabase:

### For startup_profiles:

```sql
-- Allow admin to view all startup profiles
CREATE POLICY "Admin can view all startup profiles"
ON public.startup_profiles
FOR SELECT
TO authenticated
USING (
  auth.jwt() ->> 'email' = 'admin@gmail.com'
);

-- Allow admin to update approval status
CREATE POLICY "Admin can update startup approval status"
ON public.startup_profiles
FOR UPDATE
TO authenticated
USING (
  auth.jwt() ->> 'email' = 'admin@gmail.com'
)
WITH CHECK (
  auth.jwt() ->> 'email' = 'admin@gmail.com'
);
```

### For investor_profiles:

```sql
-- Allow admin to view all investor profiles
CREATE POLICY "Admin can view all investor profiles"
ON public.investor_profiles
FOR SELECT
TO authenticated
USING (
  auth.jwt() ->> 'email' = 'admin@gmail.com'
);

-- Allow admin to update approval status
CREATE POLICY "Admin can update investor approval status"
ON public.investor_profiles
FOR UPDATE
TO authenticated
USING (
  auth.jwt() ->> 'email' = 'admin@gmail.com'
)
WITH CHECK (
  auth.jwt() ->> 'email' = 'admin@gmail.com'
);
```

## Step 4: Create Admin Account

1. Register a new user with email: `admin@gmail.com`
2. Or update an existing user's email to `admin@gmail.com` in your Supabase database

```sql
-- Update existing user to admin
UPDATE auth.users 
SET email = 'admin@gmail.com'
WHERE id = 'YOUR_USER_ID';
```

## Step 5: Test the Feature

1. Build and run the app:
   ```bash
   flutter run
   ```

2. Log in with `admin@gmail.com`

3. You should be redirected to the Admin Dashboard

4. Test the approval/rejection flow with some test profiles

## Step 6: Create Test Data (Optional)

To test the admin feature, you can create some test profiles:

```sql
-- Create a test startup profile (pending approval)
INSERT INTO startup_profiles (
  user_id, 
  business_name, 
  description, 
  industry, 
  funding_stage, 
  funding_amount_sought, 
  location,
  approval_status
) VALUES (
  'some-user-uuid',
  'Test Startup Inc',
  'A revolutionary AI-powered solution for Ethiopian businesses',
  'Technology',
  'Seed',
  250000,
  'Addis Ababa, Ethiopia',
  'pending'
);
```

## Troubleshooting

### Admin not redirected to dashboard
- Verify the email is exactly `admin@gmail.com` (case-sensitive)
- Check browser console for routing errors
- Verify `AppConstants.adminEmail` matches your admin email

### Cannot see profiles
- Check RLS policies are correctly set up
- Verify the admin user is authenticated
- Check Supabase logs for permission errors

### Approval/Rejection not working
- Verify the admin has UPDATE permissions on both tables
- Check that the `approval_status` column exists
- Look for errors in Flutter logs

### Build errors
- Run `flutter clean` and then `flutter pub get`
- Verify all imports are correct
- Check that all new files are properly created

## Changing the Admin Email

To use a different admin email:

1. Open `lib/core/constants/app_constants.dart`
2. Change the value of `adminEmail`:
   ```dart
   static const String adminEmail = 'your-admin@example.com';
   ```
3. Update the RLS policies with the new email
4. Rebuild the app

## Security Considerations

- The admin email is hardcoded for simplicity. For production, consider:
  - Adding an `is_admin` column to the users table
  - Creating a separate admin role in Supabase
  - Implementing multi-factor authentication for admin accounts
  - Logging all admin actions for audit trails

## Next Steps

After setup, you might want to:

- Add email notifications when profiles are approved/rejected
- Create a more sophisticated admin role system
- Add analytics dashboard for admin
- Implement admin action logging and audit trails
- Add ability for admins to add notes/comments on profiles

## Support

If you encounter any issues during setup, check:
1. Flutter console logs
2. Supabase database logs
3. Browser console (for web builds)
4. The project's issue tracker

Enjoy your new admin feature! 🚀
