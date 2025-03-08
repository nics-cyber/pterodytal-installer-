

---

# Pterodactyl Installer Script

This script automates the installation of the **Pterodactyl Panel** and **Wings** without requiring a domain or external IP address. It uses the server's local IP address for configuration, making it ideal for local or development environments.

---

## **Features**

- **No Domain Required:** The script uses the server's local IP address for the Panel and Wings configuration.
- **Fully Automated:** Installs all dependencies, configures the Panel, and sets up Wings in one go.
- **Secure Database:** Automatically generates a secure password for the MariaDB database.
- **Nginx Configuration:** Sets up Nginx to serve the Panel using the local IP address.
- **Wings Integration:** Configures Wings to connect to the Panel automatically.

---

## **Prerequisites**

- A clean **Ubuntu Server** (20.04 or 22.04 recommended).
- **Root access** or a user with `sudo` privileges.
- An active internet connection.

---

## **How to Run the Script**

### **Step 1: Download the Script**
Download the script to your server:

```bash
curl -Lo pterodactyl-installer.sh https://raw.githubusercontent.com/your-repo/pterodactyl-installer.sh
```

### **Step 2: Make the Script Executable**
Grant execute permissions to the script:

```bash
chmod +x pterodactyl-installer.sh
```

### **Step 3: Run the Script**
Execute the script with `sudo`:

```bash
sudo ./pterodactyl-installer.sh
```

---

## **What the Script Does**

1. **Updates the System:**
   - Ensures the system is up to date.

2. **Installs Dependencies:**
   - Installs required packages like PHP, MariaDB, Nginx, Docker, and Composer.

3. **Configures MariaDB:**
   - Creates a database and user for the Panel with a secure password.

4. **Installs the Panel:**
   - Downloads and configures the Pterodactyl Panel.
   - Sets up the environment and runs database migrations.

5. **Configures Nginx:**
   - Sets up Nginx to serve the Panel using the server's local IP address.

6. **Installs Wings:**
   - Downloads and configures Wings to connect to the Panel.

7. **Outputs Installation Details:**
   - Displays the Panel URL and database password.

---

## **Accessing the Panel**

Once the script completes, you can access the Pterodactyl Panel using the server's local IP address:

```
http://<server-ip>
```

For example, if your server's IP address is `192.168.1.100`, you would visit:

```
http://192.168.1.100
```

---

## **Post-Installation Steps**

### **1. Secure the Panel**
For production use, it's recommended to secure the Panel with SSL. You can use Let's Encrypt to obtain a free SSL certificate.

### **2. Configure Firewall**
Ensure your server's firewall is configured to allow traffic on ports `80` (HTTP) and `443` (HTTPS).

### **3. Create an Admin User**
If you didn't create an admin user during installation, you can do so by running:

```bash
sudo php /var/www/pterodactyl/artisan p:user:make
```

---

## **Troubleshooting**

### **1. Permission Errors**
If you encounter permission errors, ensure the script is run with `sudo`.

### **2. Nginx Issues**
If Nginx fails to start, check the configuration file for errors:

```bash
sudo nginx -t
```

### **3. Wings Not Connecting**
Ensure Wings is configured to connect to the correct Panel URL. You can reconfigure Wings by running:

```bash
sudo wings configure --panel-url http://<server-ip> --token <panel-api-token>
```

---

## **Contributing**

If you'd like to contribute to this project, feel free to fork the repository and submit a pull request. Please ensure your changes are well-documented and tested.

---

## **License**

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## **Credits**

- [Pterodactyl Panel](https://pterodactyl.io/) for the amazing game server management platform.
- Contributors to this repository for their awesome work.

---

Enjoy your Pterodactyl installation! 🚀

---

