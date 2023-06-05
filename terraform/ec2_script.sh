#! /bin/bash
echo "ec2 install wordpress"
sudo yum install httpd wget zip -y
sudo systemctl start httpd
sudo systemctl enable httpd
sudo wget https://wordpress.org/wordpress-latest.zip
sudo unzip wordpress-*.zip
sudo mv -f wordpress/* /var/www/html
sudo rm -rf wordpress wordpress-*.zip
echo "ec2 config wordpress"
sudo yum install -y amazon-linux-extras
sudo amazon-linux-extras enable php7.2
sudo yum clean metadata -y
sudo yum install php-cli php-pdo php-fpm php-json php-mysqlnd -y
sudo systemctl restart httpd
# install support for postgresql
sudo yum install git -y
git clone https://github.com/kevinoid/postgresql-for-wordpress.git
mv postgresql-for-wordpress/pg4wp /var/www/html/wp-content/pg4wp #Check this !
cp /var/www/html/wp-content/pg4wp/db.php  /var/www/html/wp-content/
# wget url-wpconfig/wp-config.php into /var/www/html/

# Edit wp-config for PostgreSQL commandline
