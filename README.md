# Hetzner Bandwidth Alert

Get bandwidth alert notification with Pushover.

```bash
mkdir /hetzner
cd /hetzner
wget https://raw.githubusercontent.com/1817666/Hetzner-Bandwidth-Alert/master/script.sh
chmod +x script.sh
vi script.sh
crontab -l > hetznercron
echo '0 */6 * * * /hetzner/script.sh #Hetzner Cron' >> hetznercron
crontab hetznercron
rm -rf hetznercron
```
