# ⚡ Quick Start - Admin Feature

Get your admin feature running in 5 minutes!

## 📋 Prerequisites Checklist

- [ ] Flutter environment set up
- [ ] Supabase project configured
- [ ] Database access (Supabase dashboard or CLI)

## 🚀 3-Step Setup

### Step 1: Install Dependencies (30 seconds)

```bash
cd "c:\Users\hp\Desktop\INSA Projects\ethioventure"
flutter pub get
```

### Step 2: Run Database Migration (2 minutes)

1. Open [Supabase Dashboard](https://app.supabase.com)
2. Go to **SQL Editor**
3. Copy/paste from `database_migrations/add_approval_status.sql`
4. Click **Run**

### Step 3: Set Up Admin Access (1 minute)

#### Option A: Register new admin
1. Run app: `flutter run`
2. Register with email: `admin@gmail.com`
3. Login
4. You'll see admin dashboard!

#### Option B: Update existing user
Run in Supabase SQL Editor:
```sql
UPDATE auth.users 
SET email = 'admin@gmail.com'
WHERE id = 'YOUR_USER_ID';
```

## ✅ Verify It Works

1. **Run the app**
   ```bash
   flutter run
   ```

2. **Login with admin email**
   - Email: `admin@gmail.com`
   - Password: (your password)

3. **You should see:**
   - Admin Dashboard page (not regular dashboard)
   - Statistics cards at top
   - Tabs for Startups and Investors
   - List of pending profiles

4. **Test approval flow:**
   - Tap a profile card to expand
   - Review details
   - Tap "Approve" or "Reject"
   - See success message
   - Card disappears from list

## 🎯 Common Issues & Fixes

### ❌ "Not seeing admin dashboard"
**Fix:** Verify email is exactly `admin@gmail.com` (case-sensitive)

### ❌ "Cannot see any profiles"
**Fix:** 
1. Check RLS policies (see ADMIN_SETUP_GUIDE.md)
2. Create test data (see below)

### ❌ "Approval/Rejection not working"
**Fix:**
1. Check database migration ran successfully
2. Verify `approval_status` column exists
3. Check Supabase logs for errors

### ❌ "Build errors"
**Fix:**
```bash
flutter clean
flutter pub get
flutter run
```

## 🧪 Create Test Data

Run in Supabase SQL Editor to create test profiles:

```sql
-- Create test startup (replace YOUR_USER_ID with real user ID)
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
  'YOUR_USER_ID',
  'AI Solutions Inc',
  'Revolutionary AI platform for Ethiopian businesses',
  'Technology',
  'Seed',
  500000,
  'Addis Ababa, Ethiopia',
  'pending'
);

-- Create another test startup
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
  'YOUR_USER_ID',
  'GreenTech Farms',
  'Sustainable agriculture solutions using IoT',
  'AgriTech',
  'Pre-Seed',
  250000,
  'Bahir Dar, Ethiopia',
  'pending'
);
```

## 📱 Usage Guide

### Viewing Profiles
1. Open admin dashboard
2. Switch between "Startups" and "Investors" tabs
3. Tap any card to expand details

### Approving Profile
1. Tap card to expand
2. Review all information
3. Tap green "Approve" button
4. See success message
5. Profile disappears from pending list

### Rejecting Profile
1. Tap card to expand
2. Review all information
3. Tap red "Reject" button
4. See success message
5. Profile disappears from pending list

### Refreshing Data
- Pull down on the list to refresh
- Or close/reopen the app

## 🔧 Configuration

### Change Admin Email
**File:** `lib/core/constants/app_constants.dart`

```dart
static const String adminEmail = 'your-admin@example.com';
```

### Customize Colors
**File:** `lib/core/theme/app_colors.dart`

Already using your design system:
- Primary (Action Cyan): `#00D1FF`
- Success: `#11845B`
- Error: `#BA1A1A`
- Warning: `#9A6700`

## 📚 Full Documentation

- **Complete Setup**: `ADMIN_SETUP_GUIDE.md`
- **Feature Overview**: `ADMIN_FEATURE_SUMMARY.md`
- **UI Design**: `ADMIN_UI_GUIDE.md`
- **Code Documentation**: `lib/features/admin/README.md`

## 🆘 Need Help?

1. Check logs in Flutter console
2. Check Supabase logs in dashboard
3. Review documentation files
4. Check browser console (for web builds)

## ✨ What's Next?

After basic setup works:
- [ ] Set up RLS policies (ADMIN_SETUP_GUIDE.md)
- [ ] Add multiple test profiles
- [ ] Test full approval workflow
- [ ] Configure email notifications (future enhancement)
- [ ] Add admin action logging (future enhancement)

---

**That's it! You're ready to manage approvals! 🎉**

Your admin can now review and approve/reject startup and investor applications through a beautiful, user-friendly interface.
