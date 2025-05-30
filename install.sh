#!/bin/bash

green='\033[0;32m'
nc='\033[0m'

wget https://raw.githubusercontent.com/88n77/Logo-88n77/main/logo.sh
chmod +x logo.sh
./logo.sh

setup_url="https://raw.githubusercontent.com/88n77/Aztec/main/setup.sh"
update_url="https://raw.githubusercontent.com/88n77/Aztec/main/update.sh"
delete_url="https://raw.githubusercontent.com/88n77/Aztec/main/deleted.sh"
role_url="https://raw.githubusercontent.com/88n77/Aztec/main/role.sh"
validator_url="https://raw.githubusercontent.com/88n77/Aztec/main/validator.sh"

menu_options=("Встановити" "Оновити" "Видалити" "Отримати роль" "Реєстрація валідатора" "Вийти")
PS3='Оберіть дію: '

select choice in "${menu_options[@]}"
do
    case $choice in
        "Встановити")
            echo -e "${green}Встановлення...${nc}"
            bash <(curl -s $setup_url)
            ;;
        "Оновити")
            echo -e "${green}Оновлення...${nc}"
            bash <(curl -s $update_url)
            ;;
        "Видалити")
            echo -e "${green}Видалення...${nc}"
            bash <(curl -s $delete_url)
            ;;
        "Отримати роль")
            echo -e "${green}Отримання ролі...${nc}"
            bash <(curl -s $role_url)
            ;;
        "Реєстрація валідатора")
            echo -e "${green}Реєстрація валідатора...${nc}"
            bash <(curl -s $validator_url)
            ;;
        "Вийти")
            echo -e "${green}Вихід...${nc}"
            break
            ;;
        *)
            echo "Невірний вибір!"
            ;;
    esac
done
