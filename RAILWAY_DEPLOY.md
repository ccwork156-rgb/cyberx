# Railway Deployment Guide for CyborX

## Quick Start Checklist

### 1. Prepare Your Repository

```bash
cd /home/suraj/githubb/test/jirichecker

# Initialize git (if not already done)
git init
git add .
git commit -m "Initial commit - CyborX setup for Railway"

# Create a GitHub repository and push
git remote add origin https://github.com/YOUR_USERNAME/cyborx.git
git branch -M main
git push -u origin main
```

### 2. Railway Setup

#### Step 1: Create New Project
1. Go to [Railway Dashboard](https://railway.app/dashboard)
2. Click **"New Project"**
3. Select **"Deploy from GitHub repo"**
4. Authorize Railway to access your GitHub
5. Select your `cyborx` repository

#### Step 2: Configure Build
Railway will auto-detect the Dockerfile. No changes needed.

#### Step 3: Add MySQL Database
1. In your Railway project, click **"New"**
2. Select **"Database"** → **"Add MySQL"**
3. Wait for provisioning (takes ~1-2 minutes)
4. Click on the MySQL service → **"Variables"** tab
5. Copy these values (they'll be auto-generated):
   - `MYSQLHOST`
   - `MYSQLPORT`
   - `MYSQLUSER`
   - `MYSQLPASSWORD`
   - `MYSQLDATABASE`

#### Step 4: Set Environment Variables

In your Railway service (the app, not database), go to **Variables** and add:

```bash
# Telegram Configuration
TELEGRAM_BOT_TOKEN=8391128564:AAGn8b0CVyuklbtWBU17MdAMR9IySHj6q_c
TELEGRAM_BOT_USERNAME=cyberx_official_bot
TELEGRAM_ADMIN_USERNAME=eviltesting
TELEGRAM_ADMIN_ID=7786553772
TELEGRAM_ANNOUNCE_CHAT_ID=-1003278376068
TELEGRAM_GROUP_LINK=https://t.me/+3K_LpkllbkA2ZjFl
TELEGRAM_REQUIRE_ALLOWLIST=false
TELEGRAM_ALLOWED_IDS=7786553772

# Database (from Railway MySQL Variables tab)
DB_DSN=mysql:host=${{MYSQLHOST}};dbname=${{MYSQLDATABASE}};charset=utf8mb4
DB_USER=${{MYSQLUSER}}
DB_PASS=${{MYSQLPASSWORD}}

# Session & Domain
SESSION_COOKIE_DOMAIN=.databasemanaging.com
SESSION_NAME=CYBORXSESSID
SESSION_COOKIE_LIFETIME=7200
SESSION_GC_MAXLIFETIME=7200
SESSION_SAMESITE=Lax

# Application
APP_DEBUG=false
APP_HOST=databasemanaging.com
PORT=80

# Optional: IPQualityScore (for proxy fraud detection)
IPQS_KEY=
```

#### Step 5: Configure Domain
1. Go to your Railway project → **Settings** tab
2. Scroll to **"Domains"** section
3. Click **"Add Custom Domain"**
4. Enter: `databasemanaging.com`
5. Click **"Add Domain"**
6. Railway will show DNS records to configure

#### Step 6: Configure DNS (on Railway Domains page)

Since you purchased the domain through Railway:
- DNS should be auto-configured
- If not, add these records:
  - **A Record**: `@` → Railway's IP (provided in dashboard)
  - **CNAME**: `www` → your-app.up.railway.app

#### Step 7: Deploy
1. Go to **"Deployments"** tab
2. Click **"Deploy"** (or it may auto-deploy)
3. Wait for build to complete (~2-5 minutes)
4. Once deployed, visit `https://databasemanaging.com`

---

## Database Initialization

After deployment, you need to create the tables. Connect to your Railway MySQL:

### Option 1: Using Railway Shell
1. In Railway dashboard, click on MySQL service
2. Click **"Shell"** tab
3. Run:
```bash
mysql -u $MYSQLUSER -p$MYSQLPASSWORD $MYSQLDATABASE -h $MYSQLHOST
```

### Option 2: Using phpMyAdmin or MySQL Client
```bash
mysql -h <MYSQLHOST> -u <MYSQLUSER> -p<MYSQLPASSWORD> <MYSQLDATABASE>
```

### Run SQL Schema
Copy the SQL from README.md and run it. Or use the provided schema file:

```bash
# If you created schema.sql
mysql -h <host> -u <user> -p<password> <database> < schema.sql
```

---

## Set Admin Status

After first login, set your admin status:

```sql
-- Method 1: By Telegram ID
UPDATE users SET status='admin' WHERE telegram_id='7786553772';

-- Method 2: By username
UPDATE users SET status='admin' WHERE username='eviltesting';
```

---

## Verify Deployment

### 1. Check Application
Visit: https://databasemanaging.com

You should see the Telegram login page.

### 2. Check Logs
In Railway dashboard:
- Go to your service → **"Deployments"** → Click latest deployment → **"View Logs"**

### 3. Test Login
1. Click "Sign in with Telegram"
2. Authorize the bot
3. You should be redirected to dashboard

### 4. Verify Admin Access
After login, you should see **"Admin Panel"** in the sidebar.

---

## Troubleshooting

### Build Fails

**Error: mbstring not found**
```dockerfile
# Already in Dockerfile, but verify:
RUN docker-php-ext-install mbstring pdo_mysql
```

**Error: Composer install fails**
```bash
# Check composer.json is valid
composer validate
```

### Application Errors

**500 Internal Server Error**
```bash
# Check logs in Railway
# Verify database connection variables
# Ensure APP_DEBUG=false in production
```

**Telegram Login Fails**
- Verify `TELEGRAM_BOT_TOKEN` is correct
- Check bot username matches (`cyberx_official_bot`)
- Ensure bot is added to the group

**Session Issues**
```bash
# Verify SESSION_COOKIE_DOMAIN matches your domain
# Should be: .databasemanaging.com (with leading dot)
```

**Database Connection Failed**
```bash
# In Railway Variables, ensure you're using:
DB_DSN=mysql:host=${{MYSQLHOST}};dbname=${{MYSQLDATABASE}};charset=utf8mb4
# Railway auto-injects these variables
```

### Performance Issues

**Slow queries**
```sql
-- Add indexes
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_online ON users(online_status, last_activity);
CREATE INDEX idx_proxies_user ON user_proxies(user_id);
```

**High memory usage**
- Railway free tier: 512MB RAM
- Consider upgrading to paid plan

---

## SSL/HTTPS

Railway provides **automatic SSL** via Let's Encrypt:
- No configuration needed
- HTTPS is forced automatically
- Certificate renews automatically

---

## Scaling on Railway

### Resource Usage
Monitor in Railway dashboard → **"Metrics"**

### Upgrade Plan
If you exceed free tier limits:
1. Go to Railway → **Settings** → **Billing**
2. Choose **Hobby** ($5/mo) or **Pro** ($20/mo)

### Horizontal Scaling
Railway supports multiple instances:
1. Settings → **Scaling**
2. Increase instance count
3. Add load balancer (Railway Auto)

---

## Backup Database

### Manual Backup
```bash
mysqldump -h <host> -u <user> -p<password> <database> > backup.sql
```

### Automated Backups
Use Railway's built-in backups or set up a cron job:
```bash
# Example: Daily backup at 2 AM
0 2 * * * mysqldump -h $MYSQLHOST -u $MYSQLUSER -p$MYSQLPASSWORD $MYSQLDATABASE > /backups/backup_$(date +\%Y\%m\%d).sql
```

---

## Update Deployment

### Push Updates
```bash
git add .
git commit -m "Update description"
git push origin main
```

Railway will **auto-deploy** on every push to `main`.

### Force Redeploy
1. Railway Dashboard → Your Project
2. **Deployments** tab
3. Click **"Redeploy"** on latest deployment

---

## Environment-Specific Configs

### Development (.env.local)
```env
APP_DEBUG=true
DB_DSN=mysql:host=localhost;dbname=cyborx_local;charset=utf8mb4
DB_USER=root
DB_PASS=
TELEGRAM_BOT_TOKEN=test_token
```

### Production (Railway Variables)
```env
APP_DEBUG=false
# Use Railway's auto-injected database variables
```

---

## Cost Estimation

**Railway Free Tier:**
- 500 execution hours/month
- 512MB RAM
- 1 vCPU
- 1GB disk

**Estimated Monthly Cost:**
- Small app: **Free**
- Medium traffic: **~$5-10/mo** (Hobby plan)
- High traffic: **~$20-40/mo** (Pro plan + more resources)

---

## Support Contacts

- **Telegram**: [@eviltesting](https://t.me/eviltesting)
- **Group**: [CyborX Announcements](https://t.me/+3K_LpkllbkA2ZjFl)
- **Railway Support**: [help.railway.app](https://help.railway.app)

---

## Next Steps After Deployment

1. ✅ Verify site loads: `https://databasemanaging.com`
2. ✅ Test Telegram login
3. ✅ Run database schema
4. ✅ Set admin status for your account
5. ✅ Generate first redeem code (Admin Panel)
6. ✅ Test proxy system
7. ✅ Configure payment gateways (if needed)
8. ✅ Set up monitoring/logs
9. ✅ Test on mobile devices
10. ✅ Share with users!

---

**Good luck with your deployment! 🚀**
