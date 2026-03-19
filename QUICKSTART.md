# 🚀 CyborX Quick Start Guide

## Your Configuration (Already Set ✅)

### Telegram Bot
- **Bot Token**: `8391128564:AAGn8b0CVyuklbtWBU17MdAMR9IySHj6q_c`
- **Bot Username**: `@cyberx_official_bot`
- **Your Username**: `@eviltesting`
- **Your ID**: `7786553772` (Admin)

### Telegram Group
- **Group Link**: https://t.me/+3K_LpkllbkA2ZjFl
- **Chat ID**: `-1003278376068`

### Domain
- **Primary**: https://databasemanaging.com
- **Railway Auto-Domain**: Supported

---

## ⚡ 5-Minute Deployment

### Step 1: Push to GitHub (2 min)
```bash
cd /home/suraj/githubb/test/jirichecker

git init
git add .
git commit -m "Deploy CyborX to Railway"

# Create repo on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/cyborx.git
git push -u origin main
```

### Step 2: Deploy on Railway (3 min)
1. Go to https://railway.app
2. Click **"New Project"**
3. Select **"Deploy from GitHub repo"**
4. Choose your `cyborx` repository
5. Railway will auto-build (wait ~2 min)

### Step 3: Add Database (2 min)
1. In Railway project, click **"New"**
2. Select **"Database"** → **"MySQL"**
3. Wait for provisioning (~1 min)

### Step 4: Configure Domain (1 min)
1. Railway Settings → **Domains**
2. Add: `databasemanaging.com`
3. DNS auto-configures (Railway purchased)

### Step 5: Initialize Database (2 min)
1. Click MySQL service → **Shell** tab
2. Connect:
   ```bash
   mysql -u $MYSQLUSER -p$MYSQLPASSWORD $MYSQLDATABASE -h $MYSQLHOST
   ```
3. Copy schema.sql content and paste
4. Or run:
   ```bash
   mysql -u $MYSQLUSER -p$MYSQLPASSWORD $MYSQLDATABASE -h $MYSQLHOST < /path/to/schema.sql
   ```

### Step 6: Set Admin (1 min)
```sql
UPDATE users SET status='admin' WHERE telegram_id='7786553772';
```

### Step 7: Test Login (1 min)
1. Visit: https://databasemanaging.com
2. Click "Sign in with Telegram"
3. Authorize bot
4. You're in! ✅

---

## 📋 Environment Variables

Railway auto-injects these from your MySQL:
- `MYSQLHOST`, `MYSQLPORT`, `MYSQLUSER`, `MYSQLPASSWORD`, `MYSQLDATABASE`

Already configured in `.env`:
- `TELEGRAM_BOT_TOKEN=8391128564:AAGn8b0CVyuklbtWBU17MdAMR9IySHj6q_c`
- `TELEGRAM_BOT_USERNAME=cyberx_official_bot`
- `TELEGRAM_ADMIN_ID=7786553772`
- `TELEGRAM_ANNOUNCE_CHAT_ID=-1003278376068`
- `SESSION_COOKIE_DOMAIN=.databasemanaging.com`

---

## 🎯 Post-Deployment Tasks

### 1. Generate Test Redeem Code
Login → Admin Panel → Redeem Codes → Generate
- Credits: 1000
- Status: FREE
- Count: 1

### 2. Test Features
- [ ] Daily claim (+50 credits)
- [ ] Proxy setup (Settings → Proxy)
- [ ] Card checker (Checkers page)
- [ ] Redeem code

### 3. Bot Setup
1. Open Telegram
2. Search: `@cyberx_official_bot`
3. Start the bot
4. Add bot to your group: https://t.me/+3K_LpkllbkA2ZjFl
5. Make bot an admin (for notifications)

---

## 🔧 Useful Commands

### View Logs (Railway)
Railway Dashboard → Deployments → View Logs

### Database Access
```bash
mysql -h $MYSQLHOST -u $MYSQLUSER -p$MYSQLPASSWORD $MYSQLDATABASE
```

### Check Users
```sql
SELECT id, telegram_id, username, status, credits FROM users;
```

### Set User as Admin
```sql
UPDATE users SET status='admin' WHERE telegram_id='YOUR_ID';
```

### Generate Redeem Code (SQL)
```sql
INSERT INTO redeemcodes (code, status, credits, expiry_date, isRedeemed)
VALUES ('CYBORX-TEST-FREE', 'FREE', 1000, DATE_ADD(CURDATE(), INTERVAL 30 DAY), 0);
```

---

## 📱 Quick Links

| Service | Link |
|---------|------|
| **Railway Dashboard** | https://railway.app/dashboard |
| **Railway Docs** | https://docs.railway.app |
| **Telegram BotFather** | https://t.me/botfather |
| **Your Bot** | https://t.me/cyberx_official_bot |
| **Your Group** | https://t.me/+3K_LpkllbkA2ZjFl |
| **Your Domain** | https://databasemanaging.com |

---

## 🐛 Troubleshooting

### "Login Failed"
- Check bot token in Railway variables
- Verify bot username: `@cyberx_official_bot`
- Ensure bot is in group

### "Database Connection Error"
- MySQL provisioned on Railway?
- Schema.sql executed?
- Check Railway MySQL variables

### "Admin Panel Not Showing"
```sql
UPDATE users SET status='admin' WHERE telegram_id='7786553772';
```
Then logout and login again.

### "Session Expired"
- Clear browser cookies
- Check domain matches: `databasemanaging.com`
- Railway auto-detects domain

---

## 💰 Railway Costs

**Free Tier:**
- 500 hours/month (~20 days)
- 512MB RAM
- Sufficient for testing

**Hobby ($5/mo):**
- 2000 hours/month
- 2.5GB RAM
- Better for production

**Estimate:**
- < 100 users: **Free**
- 100-1000 users: **$5-10/mo**
- 1000+ users: **$20-40/mo**

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| `README.md` | Full project documentation |
| `RAILWAY_DEPLOY.md` | Detailed Railway guide |
| `CONFIGURATION.md` | Configuration summary |
| `schema.sql` | Database schema |
| `QUICKSTART.md` | This file |

---

## ✅ Deployment Checklist

- [ ] GitHub repo created
- [ ] Code pushed to GitHub
- [ ] Railway project created
- [ ] MySQL database added
- [ ] Domain configured
- [ ] Schema.sql executed
- [ ] Admin status set
- [ ] Test login successful
- [ ] Bot added to group
- [ ] First redeem code generated

---

## 🎉 You're Done!

Your CyborX platform is now live at:
**https://databasemanaging.com**

Admin: **@eviltesting** (ID: 7786553772)

Need help? Check:
- `RAILWAY_DEPLOY.md` for detailed deployment
- `README.md` for features/API docs
- Telegram: @eviltesting

---

**Happy checking! 💳✨**
