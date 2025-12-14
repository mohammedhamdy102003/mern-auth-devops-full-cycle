#!/bin/bash
set -e

# تحديث الحزم
sudo apt update

# تثبيت المتطلبات الأساسية
sudo apt install -y wget apt-transport-https gnupg lsb-release

# إضافة مفتاح Trivy
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -

# إضافة مستودع Trivy
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list

# تحديث الحزم وتثبيت Trivy
sudo apt update
sudo apt install -y trivy

# التحقق من التثبيت
trivy --version

