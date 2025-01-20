#!/bin/bash

# Функция для вывода ошибки
error(){
  echo "Error, it's not pacman or apt"
}

# Функция обновления системы
update_system() {
  if [[ -f /etc/arch-release ]]; then
    PACKAGE_MANAGER="pacman"
    UPDATE_COMMAND="$PACKAGE_MANAGER -Syyu"
  elif [[ -f /etc/debian_version ]]; then
    PACKAGE_MANAGER="apt"
    UPDATE_COMMAND="sudo $PACKAGE_MANAGER update"
    UPGRADE_COMMAND="sudo $PACKAGE_MANAGER upgrade"
  else
    error
    exit 1
  fi

  # Меню обновления
  UP_WARNING=$(dialog --title "WARNING it will works only on apt and pacman" --menu "Select what the system will do" 10 50 3 \
      1 "Update" \
      2 "Upgrade (For Debian)" \
      3 "Back to Main Menu" 2>&1 >/dev/tty)

  case $UP_WARNING in
    1)
      sudo $UPDATE_COMMAND
      ;;
    2)
      if [[ $PACKAGE_MANAGER == "apt" ]]; then
        sudo $UPGRADE_COMMAND
      else
        dialog --msgbox "Upgrade is only available for apt-based systems!" 8 40
      fi
      ;;
    3)
      menu_main
      ;;
    *)
      error
      ;;
  esac
}

# Функция меню выключения
shutdown_menu() {
  SHUTDOWN_MENU=$(dialog --title "Shutdown Menu" --menu "Select an option" 10 50 3 \
    1 "Shutdown now" \
    2 "Shutdown in 1 minute" \
    3 "Shutdown in 5 minutes" 2>&1 >/dev/tty)

  case $SHUTDOWN_MENU in
    1)
      sudo shutdown -h now
      ;;
    2)
      sudo shutdown -h +1
      ;;
    3)
      sudo shutdown -h +5
      ;;
    *)
      dialog --msgbox "Invalid selection!" 8 40
      ;;
  esac
}

# Главное меню
menu_main() {
  MENU=$(dialog --title "Main Menu" --menu "Select an option" 10 50 4 \
    1 "Reboot" \
    2 "Shutdown" \
    3 "Update system" \
    4 "Exit" 2>&1 >/dev/tty)

  case $MENU in
    1)
      clear
      sudo reboot
      ;;
    2)
      shutdown_menu
      ;;
    3)
      update_system
      ;;
    4)
      clear
      exit 0
      ;;
    *)
      dialog --msgbox "Invalid selection!" 8 40
      ;;
  esac
}

# Запрос пароля суперпользователя
PASSWD=$(dialog --title "Sudo Password" --inputbox "Please enter your sudo password:" 8 40 2>&1 >/dev/tty)
clear

echo "$PASSWD" | sudo -S echo "" > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Wrong password. Exiting..."
  exit 1
fi

# Запуск главного меню после ввода пароля
menu_main
