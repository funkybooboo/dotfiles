# ✅ Step-by-step to reset the MariaDB root password

#### 1. Log into MariaDB as root
If you're already in (as your earlier message implies), you can skip this. If not, run:

```bash
sudo mysql -u root
```

If prompted for a password and it fails, use:
```bash
sudo mysql -u root -p
```

Or if the password isn't known, **skip grants** (see alternative below).

---

#### 2. Use the `mysql` database and reset password

Once in the MySQL prompt:

```sql
USE mysql;
```

Then reset the root password (replace `NEW_PASSWORD`):

```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'NEW_PASSWORD';
FLUSH PRIVILEGES;
EXIT;
```

---

#### ✅ If you're locked out (and can’t log in)

You’ll need to **temporarily disable authentication**:

```bash
sudo systemctl stop mysql
sudo mysqld_safe --skip-grant-tables --skip-networking &
```

Then:

```bash
mysql -u root
```

And again:

```sql
USE mysql;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'NEW_PASSWORD';
FLUSH PRIVILEGES;
EXIT;
```

Finally, stop the `mysqld_safe` process and restart MySQL:

```bash
sudo pkill -f mysqld_safe
sudo systemctl restart mysql
```

