#!/usr/bin/env bash
# Project Apario is the World's Truth Repository that was invented and started by Andrei Merlescu in 2020.
# Copyright (C) 2023  Andrei Merlescu
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
if ! command -v yum; then
  echo "Cannot run without yum"
  exit 1
fi

if ! command -v wget; then
  echo "missing wget"
  exit 1
fi

if ! command -v setsebool; then
  echo "setsebool required (SELinux)"
  exit 1
fi

if ! command -v tar; then
  echo "missing tar"
  exit 1
fi

if ! command -v systemctl; then
  echo "systemctl is required"
  exit 1
fi

sudo wget https://github.com/pdfcpu/pdfcpu/releases/download/v0.9.1/pdfcpu_0.9.1_Linux_x86_64.tar.xz
sudo tar xf pdfcpu_0.9.1_Linux_x86_64.tar.xz
sudo mv pdfcpu_0.9.1_Linux_x86_64/pdfcpu /usr/local/bin
sudo rm -f pdfcpu_0.9.1_Linux_x86_64.tar.xz
sudo rm -rf pdfcpu_0.9.1_Linux_x86_64
sudo yum install ghostscript
sudo yum install pdftotext
sudo yum install ImageMagick
sudo yum install tesseract
sudo yum install libjpeg-turbo-devel
sudo yum -y install clamav-server clamav-data clamav-update clamav-filesystem clamav clamav-scanner-systemd clamav-devel clamav-lib clamav-server-systemd
sudo setsebool -P antivirus_can_scan_system 1
sudo setsebool -P clamd_use_jit 1
sudo getsebool -a | grep antivirus
sudo sed -i -e "s/^Example/#Example/" /etc/clamd.d/scan.conf
sudo sed -i -e "s/^##LocalSocket \/var\/run\/clamd.scan\/clamd.sock/LocalSocket \/var\/run\/clamd.scan\/clamd.sock/" /etc/clamd.d/scan.conf
sudo sed -i -e "s/^Example/#Example/" /etc/freshclam.conf
sudo freshclam
sudo systemctl start clamd@scan
sudo systemctl enable clamd@scan
make build
