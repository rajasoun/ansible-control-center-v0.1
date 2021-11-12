#!/usr/bin/env bash 

function install_ansible(){
    sudo apt update
    sudo apt install software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt install ansible -y 
}

function install_ansible_roles(){
    ansible-galaxy install -r $VM_HOME/ansible-control-center/dependencies/monitoring/requirements.yml
    IP=$(ip route get 8.8.8.8 | sed -n '/src/{s/.*src *\([^ ]*\).*/\1/p;q}')

    case "$IP" in
        *192* ) 
            echo "Multipass VM.Skipping User Mgmt";;
            
        * ) echo "User Mgmt"
            ansible-galaxy install -r $VM_HOME/ansible-control-center/dependencies/user-mgmt/requirements.yml

            local USER_TEMPLATE_FILE="config/templates/createusers.yml"
            local USER_CREATE_FILE="playbooks/createusers.yml"
            if [ -f "$USER_CREATE_FILE" ]; then
                echo "$USER_CREATE_FILE Exists"
                echo "Reusing Existing Config Files"
                return 0
            fi
            echo "Generating Config Files..."
            cp "$USER_TEMPLATE_FILE" "$USER_CREATE_FILE"

            file_replace_text "_SSH_KEY_.*$" "$(cat "$SSH_KEY_PATH"/"${SSH_KEY}".pub)" "$USER_CONFIG_FILE"
            echo "$USER_CREATE_FILE  Generated"

            ansible-playbook -i inventory $USER_CREATE_FILE
        ;;
    esac
}

